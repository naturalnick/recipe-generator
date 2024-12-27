TODO

[ ] - Add Ids to the ingredients for the AI to match up to so we can link to our pantry items
[ ] - Improve image generation by adding ingredients to the prompt (issue: we asked for black bean pasta, it gave us black pasta, not whole beans)

FLOW

1. User enters pantry items
2. User opens menu
3. If user has too few pantry items, display a message saying to add more items
4. If menu was previously generated, display that menu (show warning if pantry items have changed, with option to start over)
5. If menu was not previously generated, begin menu questionaire (breakfast, lunch, serving size, etc)
6. Recipes are save to the database and displayed to the user
7. Saved recipes are marked saved and accessible from cookbook
8. Viewed recipes are marked viewed and accessible from menu (?)
   a. Viewed recipes expire after 1 week (?) and disappear from the previously viewed
   b. Non-viewed recipes are removed upon menu reset
