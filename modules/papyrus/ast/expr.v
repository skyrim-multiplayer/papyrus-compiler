module ast

import papyrus.token
import papyrus.ast

pub type Expr = InfixExpr | IntegerLiteral | FloatLiteral | BoolLiteral | StringLiteral | Ident | CallExpr | SelectorExpr | IndexExpr |
	ParExpr | PrefixExpr | EmptyExpr | ArrayInit | NoneLiteral | CastExpr



pub struct EmptyExpr {
pub:
	pos		token.Position
}

pub fn (e EmptyExpr) str() string {
	return "EmptyExpr{}"
}

pub struct CastExpr {
pub:
	pos			token.Position
	type_name	string
pub mut:
	expr		Expr
	typ			ast.Type
}

[heap]
pub struct InfixExpr {
pub mut:
	op			token.Kind
	left        Expr
	right       Expr
	pos         token.Position
	left_type	ast.Type
	right_type	ast.Type
	result_type ast.Type
}

pub struct IntegerLiteral {
pub:
	pos		token.Position
	val		string
}

pub struct NoneLiteral {
pub:
	pos		token.Position
	val		string
}

pub struct FloatLiteral {
pub:
	pos		token.Position
	val		string
}

pub struct StringLiteral {
pub:
	pos      token.Position
	val      string
}

pub struct BoolLiteral {
pub:
	pos      token.Position
	val      string
}

pub struct Ident {
pub:
	name		string
	pos			token.Position
pub mut:
	typ			ast.Type
	is_property	bool
}

pub struct RedefinedOptionalArg {
pub:
	name	string
	pos		token.Position
pub mut:
	expr	Expr
	is_used	bool // used to search for unused redefined optional arguments
}

pub struct CallArg {
pub:
	pos		token.Position
pub mut:
	expr	Expr
	typ		ast.Type
}

pub struct CallExpr {
pub mut:
	pos				token.Position
	left			Expr // `user` in `user.register()`
	obj_name		string // obj_name.name()
	name			string // left.name()
	args			[]CallArg
	redefined_args	map[string]RedefinedOptionalArg // redefined optional arguments
	return_type		ast.Type
	is_static		bool
}

// `foo.bar`
pub struct SelectorExpr {
pub mut:
	pos			token.Position
	expr		Expr // expr.field_name
	field_name	string
	typ			ast.Type
}

//arr[1]
pub struct IndexExpr {
pub:
	pos		token.Position
pub mut:
	left	Expr
	index	Expr
	typ		ast.Type
}

pub struct ParExpr {
pub:
	pos  token.Position
pub mut:
	expr Expr
}

// See: token.Kind.is_prefix
pub struct PrefixExpr {
pub:
	op			token.Kind
	pos			token.Position
pub mut:
	right		Expr
	//checker
	right_type	ast.Type
}

pub struct ArrayInit {
pub:
	typ			ast.Type
	elem_type	ast.Type
	pos			token.Position
pub mut:
	len			Expr
}

pub fn (expr Expr) is_literal() bool {
	match expr {
		FloatLiteral, 
		IntegerLiteral, 
		BoolLiteral,
		StringLiteral,
		NoneLiteral {
			return true
		}
		else {
			return false 
		}
	}
} 

pub fn (expr Expr) position() token.Position {
	// all uncommented have to be implemented
	match expr {
		CallExpr, FloatLiteral, Ident, IndexExpr, IntegerLiteral, BoolLiteral,
		SelectorExpr, StringLiteral, ParExpr, PrefixExpr, ArrayInit, NoneLiteral, CastExpr {
			return expr.pos
		}
		InfixExpr {
			left_pos := expr.left.position()
			right_pos := expr.right.position()
			return token.Position{
				line_nr: expr.pos.line_nr
				pos: left_pos.pos
				len: right_pos.pos - left_pos.pos + right_pos.len
				last_line: right_pos.last_line
			}
		}
		EmptyExpr { return token.Position{} }
		// Please, do NOT use else{} here.
		// This match is exhaustive *on purpose*, to help force
		// maintaining/implementing proper .pos fields.
	}
}