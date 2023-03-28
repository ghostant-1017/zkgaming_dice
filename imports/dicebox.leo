// The 'dicebox' program.

program dicebox.aleo {
    mapping games: u64 => u8;

    record dicebox {
        public owner: address,
        public gates: u64,

        dices: u32,
        public opponent: address,

        public game_id: u64,
    }

    transition new_dicebox(dices: u32, opponent: address) -> dicebox {
        check(dices);
        return dicebox {
            owner: self.caller,
            gates: 0u64,
            dices: dices,
            opponent: opponent,
            game_id: 0u64,
        };
    }

    transition set_game_id(db: dicebox, game_id: u64) -> dicebox {
        assert(db.game_id == 0u64);
        return dicebox {
            owner: self.caller,
            gates: 0u64,
            dices: db.dices,
            opponent: db.opponent,
            game_id: game_id
        } then finalize(game_id);
    }

    finalize set_game_id(game_id: u64) {
        // This will overflow when more than two same game_id exists;
        increment(games, game_id, 122u8);
    }

    function check(dices: u32) {
        assert(dices >= 111111u32);
        assert(dices <= 666666u32);
        for i:u8 in 0u8..6u8{
            let point: u32 = dices % 10u32;
            assert(point > 0u32);
            assert(point < 7u32);
            dices = dices / 10u32;
        }
    }
}
