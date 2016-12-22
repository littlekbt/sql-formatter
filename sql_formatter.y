class SQLFormatter
rule
  query_expression: SELECT select_list table_expression {@result.unshift [val[0], [val[1]]]; result = @result}

  select_list: SELECT_LIST

  table_expression: from_clause
                  | from_clause cond_clauses

  from_clause: FROM FROM_CONDITION {@result.push [val[0], [val[1]]]}

  # 繰り返し用
  cond_clauses: cond_clause
              | cond_clauses cond_clause

  cond_clause: cond_type condition {@result.push [val[0], [val[1]]]}
             | search_cond_type search_conditions

  cond_type: ORDER_BY
           | GROUP_BY
           | LIMIT

  search_cond_type: WHERE {@result.push [val[0]]}
                  | HAVING {@result.push [val[0]]}

  condition: ORDER_BY_CONDITION
           | GROUP_BY_CONDITION
           | LIMIT_CONDITION

  search_conditions: SEARCH_CONDITION {p "search_condtions #{val}"; @result.last.push [val[0]]}
                   # | LEFT_BAREN SEARCH_CONDITION {p "left_baren search_condtions #{val}"; @result.last.last.push [val[0], val[1]]}
                   # | SEARCH_CONDITION RIGHT_BAREN {p "search_condtions right_baren #{val}"; @result.last.last.push [val[0], val[1]]}
                   | search_conditions CONJUNCTION SEARCH_CONDITION {p "search_conditions conjunction search_conditions #{val}";@result.last.last.push val[1]; @result.last.last.push val[2]}

  # search_condition: 

end

---- inner

  def initialize
    @result     = []
    @parsed_sql = nil
  end

  # clause: String
  # after_clause: Array[String]
  def pattern(clause, after_clause)
     # ((cond)truepat|falsepat) condには、後方参照の数字を入れる。
    regexp = "(?=^#{clause}\s+.+?(\s+(?:#{after_clause.join('|')}))|)^(#{clause})\s+(?(1)(.+?)(?=\s+(?:#{after_clause.join('|')}))|(.+))"
    Regexp.new(regexp, 'i')
  end

  def split_condition(cond)
    cond.split(/(\(|\)|and|or)/i).select{|e|!e.empty? && e != " "}.each do |e|
      e.strip!
      case e
      when '('
        @q.push [:LEFT_BAREN, e]
      when ')'
        @q.push [:RIGHT_BAREN, e]
      when 'AND', 'OR', 'and', 'or'
        @q.push [:CONJUNCTION, e]
      else
        @q.push [:SEARCH_CONDITION, e]
      end
    end
  end

  def parse(str)
    @q = []
    until str.empty?
      after_text = nil
      case str
      when /^\s+/
      when /^SELECT/i
        @q.push [:SELECT, $&]
      when /^\*|^.+(?=\s+FROM)/i
        @q.push [:SELECT_LIST, $&]
      when pattern('FROM', %w(WHERE ORDER\sBY HAVING GROUP\sBY LIMIT))
        cond = $3.nil? ? $4 : $3
        @q.push [:FROM,           $2]
        @q.push [:FROM_CONDITION, cond]
      when pattern('WHERE', %w(ORDER\sBY HAVING GROUP\sBY LIMIT))
        after_text = $'
        @q.push [:WHERE, $2]
        cond = $3.nil? ? $4 : $3
        split_condition(cond)
      when pattern('ORDER\sBY', %w(HAVING GROUP\sBY LIMIT))
        cond = $3.nil? ? $4 : $3
        @q.push [:ORDER_BY,           $2]
        @q.push [:ORDER_BY_CONDITION, cond]
      when pattern('HAVING', %w(GROUP\sBY LIMIT))
        after_text = $'
        @q.push [:HAVING, $2]
        cond = $3.nil? ? $4 : $3
        split_condition(cond)
      when pattern('GROUP\sBY', %w(LIMIT))
        cond = $3.nil? ? $4 : $3
        @q.push [:GROUP_BY,           $2]
        @q.push [:GROUP_BY_CONDITION, cond]
      when /^(LIMIT)\s+(.+)/i
        @q.push [:LIMIT,           $1]
        @q.push [:LIMIT_CONDITION, $2]
      end
      str = after_text || $'
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


  # 配列が深くなった時だけ、i += 2する
  # 配列が深くならず表示する時は、iはそのまま
  # ["(", ["a", "and", "b"], ")"] => i = 2, i = 4, i = 2
  # 次の句に行った時はi = 0する。
  def format(sql_arr=parsed_sql, i=0)
    sql_arr.each.with_index do |e, n|
      if e.is_a?(Array)
        format(e, i)
        i = 0
      else
        puts " " * i + e
        if sql_arr[n + 1].is_a?(Array)
          i += 2
        end
      end
    end
  end
---- footer
