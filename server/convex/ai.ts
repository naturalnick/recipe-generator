"use node";

import { StorageActionWriter } from "convex/server";
import { v } from "convex/values";
import { JimpMime } from "jimp";
import OpenAI from "openai";
import { zodResponseFormat } from "openai/helpers/zod";
import { z } from "zod";
import { internal } from "./_generated/api";
import { action, internalAction } from "./_generated/server";
const { Jimp } = require("jimp");
const probe = require("probe-image-size");

const openai = new OpenAI();

const PantryList = z.object({
	items: z.array(z.string()),
});

const RecipeList = z.object({
	recipes: z.array(
		z.object({
			title: z.string(),
			ingredients: z.array(
				z.object({
					id: z.string(),
					name: z.string(),
					amount: z.string(),
					unit: z.string(),
				})
			),
			instructions: z.array(z.string()),
			estimatedTime: z.object({
				hours: z.number(),
				minutes: z.number(),
			}),
		})
	),
});

export const scanImage = action({
	args: {
		image: v.string(),
	},
	handler: async (ctx, args) => {
		try {
			const results = await analyzeImage(args.image);

			return { data: results ?? [] };
		} catch (error) {
			console.error(error);
			return {
				error: {
					message: JSON.stringify(error.message),
					status: error.status,
				},
			};
		}
	},
});

export const getRecipes = internalAction({
	args: {
		collectionId: v.id("collections"),
	},
	handler: async (ctx, args) => {
		try {
			const pantryList = await ctx.runQuery(internal.items.getItems);

			if (!pantryList) {
				throw new Error("No pantry list found");
			}
			const pantryListArray = pantryList.map((item) => [
				item.name,
				item._id,
			]);
			const pantryListString = pantryListArray.join(", ");

			const apiKey = process.env.OPENAI_API_KEY;
			if (!apiKey) {
				throw new Error("API key not configured");
			}

			const completion = await openai.beta.chat.completions.parse({
				model: "gpt-4o-mini",
				messages: [
					{
						role: "user",
						content: `The following is a list of available grocery items / ingredients. Provide recipes including ingredients in this list. Do not provide recipes if they contain ingredients missing from this list. ${pantryListString}`,
					},
				],
				response_format: zodResponseFormat(RecipeList, "recipes"),
			});

			const recipes: any = completion.choices[0].message.parsed?.recipes;

			if (!recipes) {
				throw new Error("No recipes found");
			}

			console.log("starting dish image generation...");
			for (const recipe of recipes) {
				// const storageId = await generateDishImage(
				// 	recipe.title,
				// 	ctx.storage
				// );
				// if (storageId) recipe.storageId = storageId;
				// else
				recipe.storageId = undefined;

				recipe.saved = false;
				recipe.collectionId = args.collectionId;
			}
			console.log("saving recipes to database...");
			await ctx.runMutation(internal.recipes.createMany, { recipes });

			return { status: 300, error: null };
		} catch (error) {
			console.error(error);
			return {
				status: 500,
				error: JSON.stringify(error.message),
			};
		}
	},
});

export async function generateDishImage(
	description: string,
	storage: StorageActionWriter
) {
	console.log(`Starting image generation for dish: ${description}`);
	try {
		const dallE = await openai.images.generate({
			model: "dall-e-3",
			prompt: `A dish of ${description} in illustrated art style.`,
			n: 1,
			size: "1024x1024",
			response_format: "url",
		});

		const url = dallE.data[0].url;
		if (!url) throw new Error("No image data generated");

		const response = await fetch(url);
		const buffer = await response.arrayBuffer();

		let probeResult = await probe(url);
		let { width, height, mime } = probeResult;

		const image = await Jimp.read(Buffer.from(buffer));

		const resized = image.resize({
			w: 500,
			h: 500,
		});

		const resizedBuffer = await resized.getBuffer(mime);

		const blob = new Blob([resizedBuffer], { type: mime });

		const result = await storage.store(blob);
		return result;
	} catch (error) {
		console.error("Error in generateDishImage:", error);
		console.error("Error details:", {
			name: error.name,
			message: error.message,
			stack: error.stack,
		});
		return null;
	}
}

export async function analyzeImage(imageData: string) {
	try {
		const apiKey = process.env.OPENAI_API_KEY;
		if (!apiKey) {
			throw new Error("API key not configured");
		}

		const completion = await openai.beta.chat.completions.parse({
			model: "gpt-4o-mini",
			messages: [
				{
					role: "user",
					content: [
						{
							type: "text",
							text: "List the grocery items in the image below. Don't list multiples or include quantities. Differentiate between types of foods (fresh tomatoes vs canned tomatoes). Ignore non-food items. Ignore brand names.",
						},
						{
							type: "image_url",
							image_url: {
								url: `data:image/png;base64,${imageData}`, // account for non png images
								detail: "low", // remove later for better scans
							},
						},
					],
				},
			],
			response_format: zodResponseFormat(PantryList, "items"),
		});

		const items = completion.choices[0].message.parsed?.items;
		console.log(items);
		return items;
	} catch (error) {
		if (error instanceof Error) {
			throw { error: error.message, status: 500 };
		}
		throw { error: "An unknown error occurred", status: 500 };
	}
}
