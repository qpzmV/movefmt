script {
fun main() {  
    let y: u64 = 100; // Define an unsigned 64-bit integer variable y and assign it a value of 100  
    let z = if (y <= 10) { // If y is less than or equal to 10  
        y = y + 1; // Increment y by 1  
    } else {  
        y = 10; // Otherwise, set y to 10  
    };  
}
}
