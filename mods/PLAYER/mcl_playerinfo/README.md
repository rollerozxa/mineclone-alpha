# PlayerInfo mod for MineClone 2

This is a helper mod for other mod to query the nodes around the player.

Every half second the mod checks which node the player is standing on, which
node is at foot and head level and stores inside a global table to be used by mods:

- `mcla_playerinfo[name].node_stand`
- `mcla_playerinfo[name].node_stand_below`
- `mcla_playerinfo[name].node_foot`
- `mcla_playerinfo[name].node_head`

## License
MIT License

