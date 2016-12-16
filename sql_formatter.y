class SQLFormatter
rule
  query_expression: SELECT select_list table_expression {@result.unshift [val[0], [val[1]]]; result = @result}

  select_list: SELECT_LIST

  table_expression: from_clause
                  | from_clause cond_clause
                  | from_clause cond_clause cond_clause
                  | from_clause cond_clause cond_clause cond_clause

  from_clause: FROM FROM_CONDITION {@result.unshift [val[0], [val[1]]]}

  cond_clause: where_clause
             | order_clause
             | having_clause

  where_clause: WHERE WHERE_CONDITION       {@result.push [val[0], [val[1]]]}

  order_clause: ORDER_BY ORDER_BY_CONDITION {@result.push [val[0], [val[1]]]}

  having_clause: HAVING HAVING_CONDITION    {@result.push [val[0], [val[1]]]}
end

---- inner

  def initialize
    @result     = []
    @parsed_sql = nil
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
      when /(?=^FROM\s+.+?(\s+(?:WHERE|ORDER\sBY|HAVING))|)^(FROM)\s+(.+?)(?(1)(?=\s+(?:WHERE|ORDER\sBY|HAVING))|)/i # ((cond)truepat|falsepat) condには、後方参照の数字を入れる。
        @q.push [:FROM,           $2]
        @q.push [:FROM_CONDITION, $3]
      when /(?=^WHERE\s+.+?(\s+(?:ORDER\sBY|HAVING))|)^(WHERE)\s+(.+?)(?(1)(?=\s+(?:ORDER\sBY|HAVING))|)/i
        @q.push [:WHERE,           $2]
        @q.push [:WHERE_CONDITION, $3]
      when /(?=^ORDER\sBY\s+.+?(\s+(?:HAVING))|)^(ORDER\sBY)\s+(.+?)(?(1)(?=\s+(?:HAVING))|)/i
        @q.push [:ORDER_BY,           $2]
        @q.push [:ORDER_BY_CONDITION, $3]
      when /^(HAVING)\s+(.+)/i
        @q.push [:HAVING,           $1]
        @q.push [:HAVING_CONDITION, $2]
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
        format(e, i)
        i = 0
      else
        puts " " * i + e
        i += 2
      end
    end
  end
---- footer
