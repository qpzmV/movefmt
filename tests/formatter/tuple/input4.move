address 0x42 {  
    module example {  
        // This function returns unit (i.e., nothing)  
        fun returns_unit() {}  
          
        // This function returns a tuple of two booleans  
        fun returns_2_values(): (bool, bool) { (true, false) }  
          
        // This function returns a tuple of a reference to a u64, a u8, a u128, and a vector of u8s  
        fun returns_4_values(x: &u64): (&u64, u8, u128, vector<u8>) { (x, 0, 1, b"foobar") }  
  
        fun examples(cond: bool) {  
            // This line is an example of a unit value being assigned to a variable  
            let () = ();  
              
            // This line is an example of a tuple value being assigned to variables x and y  
            let (x, y): (u8, u64) = (0, 1);  
              
            // This line is an example of a tuple with multiple types being assigned to variables a, b, c, and d  
            let (a, b, c, d) = (@0x0, 0, false, b"");  
  
            // Reassignment of unit value  
            () = ();  
              
            // Conditional reassignment of tuple values x and y  
            (x, y) = if (cond) (1, 2) else (3, 4);  
              
            // Reassignment of tuple values a, b, c, and d  
            (a, b, c, d) = (@0x1, 1, true, b"1");  
        }  
  
        fun examples_with_function_calls() {  
            // Calling a function that returns unit and assigning the result to a variable  
            let () = returns_unit();  
              
            // Calling a function that returns a tuple of booleans and assigning the result to variables x and y  
            let (x, y): (bool, bool) = returns_2_values();  
              
            // Calling a function that returns a tuple of multiple types and assigning the result to variables a, b, c, and d  
            let (a, b, c, d) = returns_4_values(&0);  
  
            // Reassignment using function call that returns unit  
            () = returns_unit();  
              
            // Reassignment using function call that returns a tuple of booleans  
            (x, y) = returns_2_values();  
              
            // Reassignment using function call that returns a tuple of multiple types  
            (a, b, c, d) = returns_4_values(&1);  
        }  
    }  
}