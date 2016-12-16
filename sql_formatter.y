class SQLFormatter
rule
  query_expression: SELECT select_list table_expression {@result.unshift [val[0], [val[1]]]; result = @result}

  select_list: SELECT_LIST

  table_expression: from_clause
                  | from_clause cond_clause
                  | from_clause cond_clause cond_clause
                  | from_clause cond_clause cond_clause cond_clause
                  | from_clause cond_clause cond_clause cond_clause cond_clause 
                  | from_clause cond_clause cond_clause cond_clause cond_clause cond_clause

  from_clause: FROM FROM_CONDITION {@result.unshift [val[0], [val[1]]]}

  cond_clause: cond_type condition {@result.push [val[0], [val[1]]]}

  cond_type: WHERE
           | ORDER_BY
           | HAVING
           | GROUP_BY
           | LIMIT

  condition: WHERE_CONDITION
           | ORDER_BY_CONDITION
           | HAVING_CONDITION
           | GROUP_BY_CONDITION
           | LIMIT_CONDITION
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
      when /(?=^FROM\s+.+?(\s+(?:WHERE|ORDER\sBY|HAVING|GROUP\sBY|LIMIT))|)^(FROM)\s+(.+?)(?(1)(?=\s+(?:WHERE|ORDER\sBY|HAVING|GROUP\sBY|LIMIT))|)/i # ((cond)truepat|falsepat) condには、後方参照の数字を入れる。
        @q.push [:FROM,           $2]
        @q.push [:FROM_CONDITION, $3]
      when /(?=^WHERE\s+.+?(\s+(?:ORDER\sBY|HAVING|GROUP\sBY|LIMIT))|)^(WHERE)\s+(.+?)(?(1)(?=\s+(?:ORDER\sBY|HAVING|GROUP\sBY|LIMIT))|)/i
        @q.push [:WHERE,           $2]
        @q.push [:WHERE_CONDITION, $3]
      when /(?=^ORDER\sBY\s+.+?(\s+(?:HAVING|GROUP\sBY|LIMIT))|)^(ORDER\sBY)\s+(.+?)(?(1)(?=\s+(?:HAVING|GROUP\sBY|LIMIT))|)/i
        @q.push [:ORDER_BY,           $2]
        @q.push [:ORDER_BY_CONDITION, $3]
      when /(?=^HAVING\s+.+?(\s+(?:GROUP\sBY|LIMIT))|)^(HAVING)\s+(.+?)(?(1)(?=\s+(?:GROUP\sBY|LIMIT))|)/i
        @q.push [:HAVING,           $2]
        @q.push [:HAVING_CONDITION, $3]
      when /(?=^GROUP\sBY\s+.+?(\s+(?:LIMIT))|)^(GROUP\sBY)\s+(.+?)(?(1)(?=\s+(?:LIMIT))|)/i
        @q.push [:GROUP_BY,           $2]
        @q.push [:GROUP_BY_CONDITION, $3]
      when /^(LIMIT)\s+(.+)/i
        @q.push [:LIMIT,           $1]
        @q.push [:LIMIT_CONDITION, $2]
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
