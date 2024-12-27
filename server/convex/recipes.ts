import { v } from "convex/values";
import { Id } from "./_generated/dataModel";
import { internalMutation, mutation, query } from "./_generated/server";

export const get = query({
	args: {},
	handler: async (ctx) => {
		const recipes = await ctx.db.query("recipes").collect();
		return Promise.all(
			recipes.map(async (recipe) => ({
				...recipe,
				// disabled to save storage costs
				// ...(recipe.storageId
				// 	? {
				// 			imageUrl: await ctx.storage.getUrl(
				// 				recipe.storageId as Id<"_storage">
				// 			),
				// 		}
				// 	: {}),
			}))
		);
	},
});

const recipe = v.object({
	storageId: v.optional(v.id("_storage")),
	title: v.string(),
	ingredients: v.array(
		v.object({
			id: v.id("items"),
			name: v.string(),
			amount: v.string(),
			unit: v.string(),
		})
	),
	instructions: v.array(v.string()),
	estimatedTime: v.optional(
		v.object({
			hours: v.number(),
			minutes: v.number(),
		})
	),
	saved: v.optional(v.boolean()),
});

export const create = mutation({
	args: { recipe: recipe },
	handler: async (ctx, args) => {
		const id = await ctx.db.insert("recipes", recipe);
		return id;
	},
});

export const getCollections = query({
	args: {},
	handler: async (ctx) => {
		const collections = await ctx.db.query("collections").collect();
		return collections;
	},
});

export const createCollection = mutation({
	args: {
		collection: v.object({
			title: v.string(),
			mealType: v.string(),
			isSavory: v.boolean(),
			servingSize: v.number(),
			dietary: v.array(v.string()),
		}),
	},
	handler: async (ctx, args) => {
		const id = await ctx.db.insert("collections", {
			...args.collection,
		});
		return id;
	},
});

export const remove = mutation({
	args: {
		id: v.id("recipes"),
	},
	handler: async (ctx, args) => {
		await ctx.db.delete(args.id);
	},
});

export const createMany = internalMutation({
	args: {
		recipes: v.array(recipe),
	},
	handler: async (ctx, args) => {
		for (const recipe of args.recipes) {
			await ctx.db.insert("recipes", recipe);
		}
	},
});
