module TestFunFormat {

  struct SomeOtherStruct has drop {
    some_field: u64,
  }

  fun acq(addr: address): u64/* test comment locate before acquires */acquires SomeStruct {
    let val = borrow_global<SomeStruct>(addr);
    val.some_field
  }

  fun acq22(addr: address): u64 acquires SomeStruct/* test comment locate after acquires */{
    let val = borrow_global<SomeStruct>(addr);
    val.some_field
  }

  fun acq33(addr: address): u64 acquires/* test comment locate between acquires */SomeStruct {
    let val = borrow_global<SomeStruct>(addr);
    val.some_field
  }
}
