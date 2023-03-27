// The 'zkgaming_dice' program.
import dicebox.leo;

program zkgaming_dice.aleo {
    mapping games: u64 => u8;

    record statement {
        public owner: address,
        public gates: u64,

        public num: u32,
        public point: u32,

        public game_id: u64,
        
        // Represent who makes the statement
        public signer: address,
    }

    record challenge {
        public owner: address,
        public gates: u64,

        public needed_num: u32,
        public point: u32,

        public game_id: u64,
        public signer: address,
    }

    transition initial_dicebox(dices: u32, opponent: address) -> dicebox.leo/dicebox {
        let db: dicebox = dicebox.leo/new_dicebox(dices, opponent);
        return db;
    }

    transition offer_dicebox(db: dicebox.leo/dicebox, game_id: u64) -> (dicebox.leo/dicebox, statement) {
        // We need something like game_id to mark the dicebox related the statement.
        assert(db.game_id == 0u64 );

        // set_game_id should be like a internal call in eth;
        // or we need another mapping in dicebox to ensure [offer_dicebox] is the only way to set a game_id for dicebox
        // so does the statement
        // So that anyone can not cheat. 
        let started_db: dicebox = dicebox.leo/set_game_id(db, game_id);
        let sm: statement = statement {
            owner: db.opponent,
            gates: 0u64,

            num: 1u32,
            point: 1u32,

            game_id: game_id,
            signer: self.caller
        };
        return (started_db, sm) then finalize(game_id);
    }

    // Chain remember the game_id
    finalize offer_dicebox(game_id: u64) {
        // This will overflow when game_id exists;
        increment(games, game_id, 255u8);
    }

    transition accept_dicebox(db: dicebox.leo/dicebox, sm: statement) -> (dicebox.leo/dicebox, statement) {
        assert(db.game_id == 0u64);  // Ensure the db is in a initial state
        assert(db.opponent == sm.signer); // Ensure the statement is sent by opponent
        assert(db.owner == sm.owner); // It's obvious
        let started_db: dicebox = dicebox.leo/set_game_id(db, sm.game_id);
        let started_sm: statement = statement {
            owner: db.opponent,
            gates: 0u64,
            num: sm.num,
            point: sm.point,
            game_id: sm.game_id,
            signer: self.caller,
        };
        return (started_db, started_sm);
    }

    transition response_statement(sm: statement, num: u32, point: u32) -> statement {
        assert(point > 0u32);
        assert(point < 7u32);

        if num == sm.num {
            assert(point > sm.point);
        } else {
            assert(num > sm.num);
        }
        let new_sm: statement = statement {
            owner: sm.signer,
            gates: sm.gates,

            num: num,
            point: point,

            game_id: sm.game_id,
            signer: self.caller
        };
        return new_sm;
    }

    // Consumes the dicebox and statement and generate the challenge
    transition raise_challenge(db: dicebox.leo/dicebox, sm: statement) -> challenge {
        assert(db.game_id == sm.game_id);
        assert(db.opponent == sm.signer);
        let owned_num: u32 = calculate(db.dices, sm.point);
        let needed_num: u32 = sm.num - owned_num;
        let cg: challenge = challenge {
            owner: sm.signer,
            gates: 0u64,

            needed_num: needed_num,
            point: sm.point,
            game_id: sm.game_id,
            signer: self.caller
        };
        return cg;
    }

    // Consumes the dicebox and challenge and generate the result
    transition accept_challenge(db: dicebox.leo/dicebox, cg: challenge) -> public bool {
        assert(db.game_id == cg.game_id);
        assert(db.opponent == cg.signer);

        let owned_num: u32 = calculate(db.dices, cg.point);
        if owned_num >= cg.needed_num {
            return true;
        }
        return false;
    }

    function calculate(dices: u32, point: u32) -> u32 {
        let num: u32 = 0u32;
        for i:u8 in 0u8..6u8{
            let cur: u32 = dices % 10u32;
            if cur == point {
                num += 1u32;
            }
            dices = dices / 10u32;
        }
        return num;
    }
}
