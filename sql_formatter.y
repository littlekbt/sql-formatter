class SQLFormatter
rule
  query_expression: SELECT select_list table_expression

  select_list: SELECT_LIST

  table_expression: TABLE_EXPRESSION
end

---- inner

  def initialize
  end

  def parse(str)
    @q = []
    until str.empty?
      case str
      when /^\s+/
      when /^SELECT/i
        @q.push [:SELECT, $&]
      when /^\*|^.+(?=\s+FROM)/i
        @q.push [:SELECT_LIST, $&]
      when /^FROM.+/i
        @q.push [:TABLE_EXPRESSION, $&]
      end
      str = $'
    end
    p @q
    @q.push [false, '$end']
    do_parse
  end

  def next_token
    @q.shift
  end

---- footer

parser = SQLFormatter.new
str = 'SELECT users.id, users.name FROM users INNER JOIN blogs on users.id = blogs.user_id WHERE users.id = 1'
parser.parse(str)
