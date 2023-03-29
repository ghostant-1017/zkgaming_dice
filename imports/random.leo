// The 'random' program.

program random.aleo {
    mapping ids: u64 => u8;
    record preset {
        public owner: address,
        public gates: u64,

        nonce: u64,
        public game_id: u64,
        public signer: address,
    }

    transition make_preset(game_id: u64, nonce: u64, opponent: address) -> (preset, preset) {
        let r1: preset = preset {
            owner: self.caller,
            gates: 0u64,
            nonce: nonce,
            game_id: game_id,
            signer: self.caller
        };
        let r2: preset = preset {
            owner: opponent,
            gates: 0u64,
            // unititialized nonce
            nonce: 0u64,
            game_id: game_id,
            signer: self.caller
        };
        return (r1,r2) then finalize(game_id);
    }
    
    finalize make_preset(game_id: u64) {
        // This will overflow if more than 2 games created
        increment(ids, game_id, 122u8);
    }
    // Set nonce for opponent
    transition set_nonce(pre: preset, nonce: u64) -> preset {
        assert(pre.nonce == 0u64);
        return preset {
            owner: pre.signer,
            gates: 0u64,
            nonce: nonce,
            game_id: pre.game_id,
            signer: self.caller
        };
    }
}
