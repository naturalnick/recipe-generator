import { v } from "convex/values";
import { internalQuery, mutation, query } from "./_generated/server";

export const get = query({
	args: {},
	handler: async (ctx) => {
		return await ctx.db.query("items").collect();
	},
});

export const create = mutation({
	args: { name: v.string() },
	handler: async (ctx, args) => {
		const item = {
			name: args.name,
			status: "IN",
		};

		const id = await ctx.db.insert("items", item);
		return id;
	},
});

export const updateStatus = mutation({
	args: {
		id: v.id("items"),
		status: v.string(),
	},
	handler: async (ctx, args) => {
		await ctx.db.patch(args.id, { status: args.status });
	},
});

export const updateName = mutation({
	args: {
		id: v.id("items"),
		name: v.string(),
	},
	handler: async (ctx, args) => {
		await ctx.db.patch(args.id, { name: args.name });
	},
});

export const remove = mutation({
	args: {
		id: v.id("items"),
	},
	handler: async (ctx, args) => {
		await ctx.db.delete(args.id);
	},
});

export const createMany = mutation({
	args: {
		items: v.array(v.string()),
	},
	handler: async (ctx, args) => {
		const items = args.items.map((item) => ({
			name: item,
			status: "IN",
		}));
		for (const item of items) {
			await ctx.db.insert("items", item);
		}
	},
});

export const getItems = internalQuery({
	args: {},
	handler: async (ctx, args) => {
		return await ctx.db.query("items").collect();
	},
});
