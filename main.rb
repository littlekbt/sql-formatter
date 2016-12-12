require './sql_formatter.tab.rb'

parser = SQLFormatter.new
str = 'select id, name from users where users.id = 1'
parser.parse(str)
parser.format
