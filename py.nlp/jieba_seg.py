#encoding=utf-8
import jieba
import sys

"""
# jieba API
"read a text or file for segmenting"
if len(sys.argv) < 2:
	print ""
else:
	text = sys.argv[1]
	seg_list = jieba.cut(text)   # cut(,cut_all=True/False)
	print " ".join(seg_list)
"""

from bottle import route, run, template
from bottle import request, response
from bottle import error

@error(404)
def error404(error):
    return {"result": [] }

@route('/jiebacut', method='POST')
def jieba_cut():
	text = request.query.get('text')	
	seg_list = jieba.cut(text)
	#response.content_type = "application/json"
	words = {"result": [w for w in seg_list] }
	return words

run(host='localhost', port=8081, debug=True)







# SUG: allow -h for usage
