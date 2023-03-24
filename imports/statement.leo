// The 'statement' program.

program statement.aleo {
    record statement {
        public owner: address,
        public gates: u64,

        public num: u32,
        public point: u32,

        public game_id: u64,
        
        // Represent who makes the statement
        public signer: address,
    }

    // create a initial statement owned by opponent
    transition create_statement(opponent: address, game_id: u64) -> statement {
        return statement {
            owner: opponent,
            gates: 0u64,

            num: 1u32,
            point: 1u32,

            game_id: game_id,
            signer: self.caller
        };
    }

    transition make_statement(sm: statement, num: u32, point: u32) -> statement {
        assert(point > 0u32);
        assert(point < 7u32);

        if num == sm.num {
            assert(point > sm.point);
        } else {
            assert(num > sm.num);
        }
        return statement {
            owner: sm.signer,
            gates: sm.gates,

            num: num,
            point: point,

            game_id: sm.game_id,
            signer: self.caller
        };
    }
}
