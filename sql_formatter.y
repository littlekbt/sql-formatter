class SQLFormatter
rule
  query_expression: SELECT select_list table_expression {result = [val[0], [val[1], val[2]]]}

  select_list: SELECT_LIST

  table_expression: TABLE_EXPRESSION
end

---- inner

  def initialize
    @parsed_sql = []
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
    @q.push [false, '$end']
    @parsed_sql = do_parse
  end

  def next_token
    @q.shift
  end

  def parsed_sql
    @parsed_sql
  end

  def format(sql_arr=parsed_sql, i=0)
    sql_arr.each do |e|
      if e.is_a?(Array)
        i += i + 2
        format(e, i)
      else
        puts " " * i + e
      end
    end
  end

---- footer
