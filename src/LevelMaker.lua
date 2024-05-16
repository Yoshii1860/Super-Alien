--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}
    local poles = {}
    local flag

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- whether locked block already spawned
    local locked = false
    -- whether key spawned or not
    local spawned = false
    -- lockedBlock object to reference it
    local lockedBlock
    -- Color of lockedBlock to give key same color
    local lockedColor = 0

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 and x > 1 and x < width then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 and x > 2 and x < width - 3 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 and x > 2 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- spawn a key for locked block
            -- create the key object, insert it into the objects list
            if math.random(20) == 1 and x > 2 and x < width - 3 and locked and not spawned then
                table.insert(objects,
                    GameObject {
                        texture = 'keys-locks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        frame = lockedColor - #LOCKS,
                        collidable = true,
                        consumable = true,
                        solid = false,

                        onConsume = function()
                            gSounds['pickup']:play()
                            lockedBlock.locked = false
                        end
                    }
                )
                spawned = true
            -- chance to spawn a block
            elseif math.random(8) == 1 and x > 2 and x < width - 3 then
                    -- jump block
                    table.insert(objects,
                        GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    })
            -- chance to spawn a locked block
            elseif math.random(20) == 1 and x > 2 and x < width - 3 and not locked and not spawned then
                local lockIndex = 0
                lockedBlock = GameObject {
                    texture = 'keys-locks',
                    x = (x - 1) * TILE_SIZE,
                    y = (blockHeight - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,

                    frame = math.random(5,8),
                    collidable = true,
                    hit = false,
                    solid = true,
                    locked = true,
                    onCollide = function(obj)
                        if obj.locked then
                            gSounds['empty-block']:play()
                        elseif not obj.locked then
                            gSounds['unlock']:play()
                            for i, v in ipairs(objects) do
                                if v == lockedBlock then
                                    lockIndex = i
                                end
                                local index = 0
                                for _, v in ipairs(poles) do
                                    v.x = (width - 3) * TILE_SIZE
                                    v.y = (3 + index) * TILE_SIZE
                                    index = index + 1
                                end
                                flag.x = ((width - 3) * TILE_SIZE) + (TILE_SIZE / 2)
                                flag.y = (3) * TILE_SIZE
                            end
                            table.remove(objects, lockIndex)
                        end
                    end
                }
                lockedColor = lockedBlock.frame
                locked = true
                table.insert(objects, lockedBlock)
            end
        end
    end

    if not spawned then
        table.insert(objects,
            GameObject {
                texture = 'keys-locks',
                x = (width - 1) * TILE_SIZE,
                y = (1) * TILE_SIZE,
                width = 16,
                height = 16,

                frame = math.random(#KEYS),
                collidable = true,
                consumable = true,
                solid = false,

                onConsume = function()
                    gSounds['pickup']:play()
                    lockedBlock.locked = false
                end
            }
        )
        spawned = true
    end

    local randomColor = math.random(#POLES)
    for i = 1, 3 do
        local pole = GameObject {
            texture = 'flags',
            x = (width + 1) * TILE_SIZE,
            y = (2 + i) * TILE_SIZE,
            width = 16,
            height = 16,
            frame = POLES[randomColor][i],
            collidable = true,
            solid = false,
        }
        table.insert(poles, pole)
        table.insert(objects, pole)
    end
    flag = GameObject {
        texture = 'flags',
        x = (width + 1) * TILE_SIZE,
        y = (3 + 4) * TILE_SIZE,
        width = 16,
        height = 16,
        frame = FLAGS[randomColor],
        collidable = true,
        solid = false,
        consumable = true,

        onConsume = function(player, object)
            gSounds['music']:stop()
            gSounds['victory']:play()

            while gSounds['victory']:isPlaying() do
                love.timer.sleep(0.1)
            end

            gSounds['music']:play()
            gStateMachine:change('play', {
                mapWidth = width,
                newScore = player.score
            })
        end
    }
    table.insert(objects, flag)

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end