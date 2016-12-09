SQL formatter draft

```
q = SQLFomatter.new("SELECT id, name From users INNER JOIN blogs users.id = blogs.user_id WHERE users.created_at > '2016/10/31' AND blogs.category = 1")
q.scan
# [
#   [:KEYWORD, 'SELECT'], [:COLUMN, 'id'], [:COLUMN, 'name'], 
#   [:KEYWORD, 'FROM'], [:TABLE, 'users'], 
#   [:KEYWORD, 'INNER JOIN'], [:TABLE, 'blogs'], [:COLUMN, 'users.id'], [:OPERATOR, '='], [:COLUMN, 'blogs.user_id']
#   [:KEYWORD, 'WHERE'], 
#   [:COLUMN, 'users.created_at'], [:OPERATOR, '>'], [:DATA, '2016/10/31'], 
#   [:KEYWORD, 'AND'], 
#   [:COLUMN, 'blogs.category'], [:OPERATOR, '='], [:DATA, '1']
# ]

q.parse

q.parse.to_s
# SELECT
#   id, name
# FROM
#   users 
#   INNER JOIN blogs 
#     users.id = blogs.user_id  
# WHERE
#   users.created_at > 2016/10/31
#   AND
#   blogs.category = 1

q.format
```

## Scanner
lexとして動く。
トークンに分解する。


## Parser
構文木を作る。


## Formatter
フォーマットする。

### whereだけ、とか取れるようにする。
