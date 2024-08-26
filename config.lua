Config = {}

-- Configuration for peds
Config.Peds = {
    [1] = {
        model = 'mp_m_shopkeep_01',
        coords = vector4(26.72, -1343.64, 28.5, 183.22), -- Change Z-coordinate as needed
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        shopName = 'General Store',  -- Individual shop name
        items = {
            [1] = {
                name = 'Water Bottle',
                model = 'water_bottle',
                description = 'Fresh and clean water',
                cost = 500
            },
            [2] = {
                name = 'Sandwich',
                model = 'sandwich',
                description = 'Freshly baked bread',
                cost = 300
            }
        }
    },

    -- Add more peds and items as needed with their respective shop names
}

-- Note: Adjust Z-coordinates of peds in `Config.Peds` as needed to align with the ground coordinates.
-- Use `vector4(X, Y, Z, heading)` where `Z` might need to be decreased to ensure peds are ground-aligned.
