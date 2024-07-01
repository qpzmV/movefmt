/// test_point: Multiple blank lines between use statements

module BlockLine {
    // Multiple blank lines between statements
    use aptos_std::type_info::{
        /* use_item before */ Self,
        TypeInfo
    };

    use aptos_framework::coin::{
        Self,

        /* use_item before */ Coin
    };

}
