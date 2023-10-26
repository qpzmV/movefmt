module econia::incentives {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin::{Self, Coin};
    use aptos_std::type_info::{Self, TypeInfo};
    use econia::resource_account;
    use econia::tablist::{Self, Tablist};
    use std::signer::address_of;
    use std::vector;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Friends >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    friend econia::registry;
    friend econia::market;

    // Friends <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Integrator fee store tier parameters for a given tier.
    struct IntegratorFeeStoreTierParameters has drop, store {
        /// Nominal amount divisor for taker quote coin fee reserved for
        /// integrators having activated their fee store to the given
        /// tier. For example, if a transaction involves a quote coin
        /// fill of 1000000 units and the fee share divisor at the given
        /// tier is 4000, integrators get 1/4000th (0.025%) of the
        /// nominal amount (250 quote coin units) in fees at the given
        /// tier. Instituted as a divisor for optimized calculations.
        /// May not be larger than the
        /// `IncentiveParameters.taker_fee_divisor`, since the
        /// integrator fee share is deducted from the taker fee (with
        /// the remaining proceeds going to an `EconiaFeeStore` for the
        /// given market).
        fee_share_divisor: u64,
        /// Cumulative cost, in utility coin units, to activate to the
        /// current tier. For example, if an integrator has already
        /// activated to tier 3, which has a tier activation fee of 1000
        /// units, and tier 4 has a tier activation fee of 10000 units,
        /// the integrator only has to pay 9000 units to activate to
        /// tier 4.
        tier_activation_fee: u64,
        /// Cost, in utility coin units, to withdraw from an integrator
        /// fee store. Shall never be nonzero, since a disincentive is
        /// required to prevent excessively-frequent withdrawals and
        /// thus transaction collisions with the matching engine.
        withdrawal_fee: u64
    }

    /// Incentive parameters for assorted operations.
    struct IncentiveParameters has drop, key {
        /// Utility coin type info. Corresponds to the phantom
        /// `CoinType` (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`) of
        /// the coin required for utility purposes. Set to `APT` at
        /// mainnet launch, later the Econia coin.
        utility_coin_type_info: TypeInfo,
        /// `Coin.value` required to register a market.
        market_registration_fee: u64,
        /// `Coin.value` required to register as an underwriter.
        underwriter_registration_fee: u64,
        /// `Coin.value` required to register as a custodian.
        custodian_registration_fee: u64,
        /// Nominal amount divisor for quote coin fee charged to takers.
        /// For example, if a transaction involves a quote coin fill of
        /// 1000000 units and the taker fee divisor is 2000, takers pay
        /// 1/2000th (0.05%) of the nominal amount (500 quote coin
        /// units) in fees. Instituted as a divisor for optimized
        /// calculations.
        taker_fee_divisor: u64,
        /// 0-indexed list from tier number to corresponding parameters.
        integrator_fee_store_tiers: vector<IntegratorFeeStoreTierParameters>
    }


    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Genesis parameters >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Genesis parameter.
    const MARKET_REGISTRATION_FEE: u64 =  204918032;
    /// Genesis parameter.
    const UNDERWRITER_REGISTRATION_FEE: u64 = 81967;
    /// Genesis parameter.
    const CUSTODIAN_REGISTRATION_FEE: u64 =   81967;
    /// Genesis parameter.
    const TAKER_FEE_DIVISOR: u64 =             2000;
    /// Genesis parameter.
    const FEE_SHARE_DIVISOR_0: u64 =          10000;
    /// Genesis parameter.
    const FEE_SHARE_DIVISOR_1: u64 =           8333;
    /// Genesis parameter.
    const FEE_SHARE_DIVISOR_2: u64 =           7692;
    /// Genesis parameter.
    const FEE_SHARE_DIVISOR_3: u64 =           7143;
    /// Genesis parameter.
    const FEE_SHARE_DIVISOR_4: u64 =           6667;
    /// Genesis parameter.
    const FEE_SHARE_DIVISOR_5: u64 =           6250;
    /// Genesis parameter.
    const FEE_SHARE_DIVISOR_6: u64 =           5882;
    /// Genesis parameter.
    const TIER_ACTIVATION_FEE_0: u64 =            0;
    /// Genesis parameter.
    const TIER_ACTIVATION_FEE_1: u64 =      1639344;
    /// Genesis parameter.
    const TIER_ACTIVATION_FEE_2: u64 =     24590163;
    /// Genesis parameter.
    const TIER_ACTIVATION_FEE_3: u64 =    327868852;
    /// Genesis parameter.
    const TIER_ACTIVATION_FEE_4: u64 =   4098360655;
    /// Genesis parameter.
    const TIER_ACTIVATION_FEE_5: u64 =  49180327868;
    /// Genesis parameter.
    const TIER_ACTIVATION_FEE_6: u64 = 573770491803;
    /// Genesis parameter.
    const WITHDRAWAL_FEE_0: u64 =           1639344;
    /// Genesis parameter.
    const WITHDRAWAL_FEE_1: u64 =           1557377;
    /// Genesis parameter.
    const WITHDRAWAL_FEE_2: u64 =           1475409;
    /// Genesis parameter.
    const WITHDRAWAL_FEE_3: u64 =           1393442;
    /// Genesis parameter.
    const WITHDRAWAL_FEE_4: u64 =           1311475;
    /// Genesis parameter.
    const WITHDRAWAL_FEE_5: u64 =           1229508;
    /// Genesis parameter.
    const WITHDRAWAL_FEE_6: u64 =           1147540;

    // Genesis parameters <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Caller is not Econia, but should be.
    const E_NOT_ECONIA: u64 = 0;
    /// Type does not correspond to an initialized coin.
    const E_NOT_COIN: u64 = 1;
    /// Passed fee store tiers vector is empty.
    const E_EMPTY_FEE_STORE_TIERS: u64 = 2;
    /// Indicated fee share divisor for given tier is too big.
    const E_FEE_SHARE_DIVISOR_TOO_BIG: u64 = 3;
    /// The indicated fee share divisor for a given tier is less than
    /// the indicated taker fee divisor.
    const E_FEE_SHARE_DIVISOR_TOO_SMALL: u64 = 4;
    /// Market registration fee is less than the minimum.
    const E_MARKET_REGISTRATION_FEE_LESS_THAN_MIN: u64 = 5;
    /// Custodian registration fee is less than the minimum.
    const E_CUSTODIAN_REGISTRATION_FEE_LESS_THAN_MIN: u64 = 6;
    /// Taker fee divisor is less than the minimum.
    const E_TAKER_DIVISOR_LESS_THAN_MIN: u64 = 7;
    /// The wrong number of fields are passed for a given tier.
    const E_TIER_FIELDS_WRONG_LENGTH: u64 = 8;
    /// The indicated tier activation fee is too small.
    const E_ACTIVATION_FEE_TOO_SMALL: u64 = 9;
    /// The indicated withdrawal fee is too big.
    const E_WITHDRAWAL_FEE_TOO_BIG: u64 = 10;
    /// The indicated withdrawal fee is too small.
    const E_WITHDRAWAL_FEE_TOO_SMALL: u64 = 11;
    /// Type is not the utility coin type.
    const E_INVALID_UTILITY_COIN_TYPE: u64 = 12;
    /// Not enough utility coins provided.
    const E_NOT_ENOUGH_UTILITY_COINS: u64 = 13;
    /// Too many integrator fee store tiers indicated.
    const E_TOO_MANY_TIERS: u64 = 14;
    /// Indicated tier is not higher than existing tier.
    const E_NOT_AN_UPGRADE: u64 = 15;
    /// An update to the incentive parameters set indicates a reduction
    /// in fee store tiers.
    const E_FEWER_TIERS: u64 = 16;
    /// The cost to activate to tier 0 is nonzero.
    const E_FIRST_TIER_ACTIVATION_FEE_NONZERO: u64 = 17;
    /// Custodian registration fee is less than the minimum.
    const E_UNDERWRITER_REGISTRATION_FEE_LESS_THAN_MIN: u64 = 18;
    /// Depositing to an integrator fee store would result in an
    /// overflow.
    const E_INTEGRATOR_FEE_STORE_OVERFLOW: u64 = 19;
    /// Depositing to an Econia fee store would result in an overflow.
    const E_ECONIA_FEE_STORE_OVERFLOW: u64 = 20;
    /// Depositing to a utility coin store would result in an overflow.
    const E_UTILITY_COIN_STORE_OVERFLOW: u64 = 21;
    /// There is no tier with given number.
    const E_INVALID_TIER: u64 = 22;
    /// Cumulative activation fee for new tier is not greater than that
    /// of current tier.
    const E_TIER_COST_NOT_INCREASE: u64 = 23;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Buy direction flag, as defined in `market.move`.
    const BUY: bool = false;
    /// Index of fee share in vectorized representation of an
    /// `IntegratorFeeStoreTierParameters`.
    const FEE_SHARE_DIVISOR_INDEX: u64 = 0;
    /// `u64` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 64, 2))`.
    const HI_64: u64 = 0xffffffffffffffff;
    /// Maximum number of integrator fee store tiers is largest number
    /// that can fit in a `u8`.
    const MAX_INTEGRATOR_FEE_STORE_TIERS: u64 = 0xff;
    /// Minimum possible divisor for avoiding divide-by-zero error,
    /// including during denominator calculation for a `SELL` in
    /// `calculate_max_quote_match()`.
    const MIN_DIVISOR: u64 = 2;
    /// Minimum possible flat fee, required to disincentivize excessive
    /// bogus transactions.
    const MIN_FEE: u64 = 1;
    /// Number of fields in an `IntegratorFeeStoreTierParameters`.
    const N_TIER_FIELDS: u64 = 3;
    /// Sell direction flag, as defined in `market.move`.
    const SELL: bool = true;
    /// Index of tier activation fee in vectorized representation of an
    /// `IntegratorFeeStoreTierParameters`.
    const TIER_ACTIVATION_FEE_INDEX: u64 = 1;
    /// Index of withdrawal fee in vectorized representation of an
    /// `IntegratorFeeStoreTierParameters`.
    const WITHDRAWAL_FEE_INDEX: u64 = 2;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Initialize the module  
fun init_module(  
    // A reference to the signer  
    econia: &signer  
) acquires  
    // The incentive parameters  
    IncentiveParameters  
{  
    // Vectorize fee store tier parameters  
    let integrator_fee_store_tiers = vector[  
        // Tier 0 parameters  
        vector[//comment
        FEE_SHARE_DIVISOR_0,  
               TIER_ACTIVATION_FEE_0,  
               WITHDRAWAL_FEE_0],  
        // Tier 1 parameters  
        vector[FEE_SHARE_DIVISOR_1,  
        //comment
               TIER_ACTIVATION_FEE_1,  
               WITHDRAWAL_FEE_1],  
        // Tier 2 parameters  
        vector[FEE_SHARE_DIVISOR_2, 
                //comment 
               TIER_ACTIVATION_FEE_2,  
               WITHDRAWAL_FEE_2],  
        // Tier 3 parameters  
        vector[/*comment*/FEE_SHARE_DIVISOR_3,  
               TIER_ACTIVATION_FEE_3/*comment*/,  
               WITHDRAWAL_FEE_3],  
        // Tier 4 parameters  
        vector[FEE_SHARE_DIVISOR_4,  
               TIER_ACTIVATION_FEE_4, /*comment*/ 
               WITHDRAWAL_FEE_4],  
        // Tier 5 parameters  
        vector[FEE_SHARE_DIVISOR_5,  
               /*comment*/TIER_ACTIVATION_FEE_5,  
               WITHDRAWAL_FEE_5],  
        // Tier 6 parameters  
        vector[FEE_SHARE_DIVISOR_6,  
               TIER_ACTIVATION_FEE_6,  
               WITHDRAWAL_FEE_6]];  /*comment*/
}
}