use crate::core::token_tree::{Comment, CommentKind};
use commentfmt::{shape::*, comment::*, Config};

impl Comment {
    /// format comment
    /// exampls `//   this is a comment` to `// this is a comment`,etc.
    pub fn format(
        &self,
        _convert_line: impl Fn(
            u32, // offset
        ) -> u32, // line number
    ) -> String {
        unimplemented!()
    }

    pub fn comment_kind(&self) -> CommentKind {
        if self.content.starts_with("//") {
            CommentKind::DocComment
        } else {
            CommentKind::BlockComment
        }
    }

    fn format_doc_comment_with_multi_star(
        &self,
        block_indent: usize, 
        alignment: usize,
        config: &Config
    ) -> String {
        let mut result = self.content.to_string();
        let block_style = false;
        let indent = Indent::new(block_indent, alignment);
        let shape = Shape {
            width: config.max_width(),
            indent,
            offset: 0,
        };

        let mut cmt_str = String::from("");
        cmt_str.push_str(result.as_str());
        if let Some(comment) = rewrite_comment(&cmt_str, block_style, shape, config) {
            result = comment;
        }
        result
    }

    pub fn format_comment(
        &self,
        kind: CommentKind,
        block_indent: usize, 
        alignment: usize,
        config: &Config
    ) -> String {
        if CommentKind::DocComment == kind {
            self.content.clone()
        } else {
            self.format_doc_comment_with_multi_star(block_indent, alignment, config)
        }
    }
}

// fn add_space_for_comments(input: &str) -> String {
//     let mut output = String::new();
//     for line in input.lines() {
//         let trimmed = line.trim();
//         let start_position = line.find(trimmed).unwrap_or(0);  
//         output.push_str(&line[0..start_position]);
//         if trimmed.starts_with("///") && trimmed.chars().nth(3).map_or(true, |c| c != ' ') {
//             output.push_str(&format!("/// {}", &trimmed[3..]));
//         }
//         else if trimmed.starts_with("//!") && trimmed.chars().nth(3).map_or(true, |c| c != ' ') {
//             output.push_str(&format!("//! {}", &trimmed[3..]));
//         }
//         else if trimmed.starts_with("//*") && trimmed.chars().nth(3).map_or(true, |c| c != ' ') {
//             output.push_str(&format!("//* {}", &trimmed[3..]));
//         }
//         else if trimmed.starts_with("//") && trimmed.chars().nth(2).map_or(
//             true, |c| c != ' ' && c != '/' && c != '#') {
//             output.push_str(&format!("// {}", &trimmed[2..]));
//         }
//         else if trimmed.starts_with("/*") && trimmed.ends_with("*/") {  
//             // process single block comment
//             let trimmed_cmt = &trimmed[2..trimmed.len() - 2].trim();
//             output.push_str(&format!("/* {} */", &trimmed_cmt));  
//         } else if trimmed.starts_with('*') {  
//             // process each line of multi-line block comment
//             if trimmed == "*/" {
//                 output.push_str("*/");
//             }
//             else if trimmed.ends_with("*/") {
//                 if trimmed.chars().nth(1).map_or(true, |c| c != ' ')  {
//                     output.push_str(&format!("* {}\n{}*/", &trimmed[1..trimmed.len() - 2], &line[0..start_position]));
//                 } else {
//                     output.push_str(&format!("*{}\n{}*/", &trimmed[1..trimmed.len() - 2], &line[0..start_position]));  
//                 }
//             } 
//             else {
//                 if trimmed.chars().nth(1).map_or(true, |c| c != ' ') {
//                     output.push_str(&format!("* {}", &trimmed[1..]));
//                 } else {
//                     output.push_str(&format!("*{}", &trimmed[1..]));
//                 }
//                 output.push('\n');
//             }
//         } else {
//             output.push_str(trimmed);
//             let end_pos = start_position + trimmed.len();
//             // tracing::debug!("output = {}", output);
//             // tracing::debug!("line.len = {}, start_position = {}, end_pos = {}", line.len(), start_position, end_pos);
//             output.push_str(&line[end_pos..]);
//             if !trimmed.starts_with("//") {
//                 output.push('\n');
//             }
//         }
//     }
//     // tracing::debug!("input = {:?}, output = {:?}", input, output);
//     output
// }      

#[test]
fn test_rewrite_comment_1() {
    // let orig = "/* This is a multi-line\n * comment */\n\n// This is a single-line comment";
    let orig = "\n/**  \n         * This function demonstrates various examples using tuples.  \n         * It includes assignments to tuple variables and reassignments using conditional statements.  \n*/";
    // let orig = "
    // //      this is a comment
    // ";
    
    let block_style = true;
    // let style = CommentStyle::SingleBullet;
    let indent = Indent::new(4, 0);
    let shape = Shape {
        width: 100,
        indent,
        offset: 0,
    };

    let config = &Config::default();
    if let Some(comment) = rewrite_comment(orig, block_style, shape, config) {
        println!("{}", comment);
    }
}

#[test]    
fn test_cmt_add_space() {  
    let examples = vec![  
        "//comment_content",  
        "///comment_content",  
        "//!comment_content",  
        "//*comment_content",  
        "/*!comment_content*/",  
        "/**comment_content*/",  
        r#"    
        /*    
        *comment_content1   
        *comment_content2*/    
        "#,
        "/**  \n         * This function returns a tuple containing two boolean values.  \n         */"
    ];  
    
    for (idx, example) in examples.into_iter().enumerate() {
        // let style = comment_style(example, false);        
        let output = add_space_for_comments(example);    
        println!("示例{}:\n输入:\n{}\n输出:\n{}\n", idx + 1, example, output);    
    }    
}
