// The 'challenge' program.

program challenge.aleo {
    record challenge {
        public owner: address,
        public gates: u64,

        public needed_num: u32,
        public point: u32,

        public game_id: u64,
        public signer: address,
    }

    transition new_challenge(needed_num: u32, point: u32, opponent: address, game_id: u64) -> challenge {
        assert(point > 0u32);
        assert(point < 7u32);
        return challenge {
            owner: opponent,
            gates: 0u64,

            needed_num: needed_num,
            point: point,
            game_id: game_id,
            signer: self.caller
        };
    }
}
