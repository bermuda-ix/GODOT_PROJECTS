class_name SaveLoadScores extends Node

enum REQUEST_TYPE{NONE, POST, GET}

@onready var current_request_type : REQUEST_TYPE = REQUEST_TYPE.NONE
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var rich_text_label: RichTextLabel = $RichTextLabel
var highscore_test : Dictionary

signal score_sent
signal scores_recieved(response_text : String)

func _ready():
	http_request.request_completed.connect(_on_request_completed)
	#http_request.request("http://localhost:8080/hello")
	#highscore_test={
		#"Difficulty":"Easy",
		#"Name": "BEST",
		#"Score": 26
	#}
	#send_score()

func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print_debug("ruh roh raggy")
		return
	
	if response_code != 200:
		print_debug("Server borked: ", response_code)
		print_debug(body.get_string_from_utf8())
		return
	
	elif response_code == 200:
		if current_request_type==REQUEST_TYPE.POST:
			score_sent.emit()
		elif current_request_type==REQUEST_TYPE.GET:
			var response_txt = body.get_string_from_utf8()
			scores_recieved.emit(response_txt)
	
	var response_txt = body.get_string_from_utf8()
	print("Request result: ", result)
	print("HTTP response code: ", response_code)
	#print("Response body: ", body.get_string_from_utf8())
	print_debug("Note that says 'Ere ya go: '")
	#print_debug(response_txt)
	#score_sent.emit()
	#var json = JSON.new()
	#var parsed_data = json.parse_string(response_txt)
	#var score_text := ""
	#var data_arrayed = parsed_data.get_data() as Array[Array]
	#var hi ghscore_dict = parsed_data.result
	#var dictKeys = highscore_dict.keys()
	#print_debug(parsed_data.size())
	#for i in range(parsed_data.size()-1, -1, -1):
		#var _name = parsed_data[i]["Name"]
		#var _score = parsed_data[i]["Score"]
		#score_text += str(_name)+": "+str(_score)+"\n"
		#
	#rich_text_label.text=str(score_text)
	#scores_recieved.emit(response_txt)

func dictionarafy_response(_reponse : Array) -> Dictionary:
	var current_scores
	return {}

func send_score(_difficulty := "EASY", _name := "TEST", _score := 0) -> void:
	current_request_type=REQUEST_TYPE.POST
	var _score_entry={
		"Difficulty":_difficulty,
		"Name":_name,
		"Score":_score
	}
	var json = JSON.stringify(_score_entry)
	var headers = ["Content-Type: application/json"]
	print_debug(json)
	var err = http_request.request(
		"http://127.0.0.1:8080/score",
		headers,
		HTTPClient.METHOD_POST,
		json)
	
	
	if err != OK:
		print("ruh roh raggy")
		rich_text_label.text="ruh rog raggy"
	else:
		rich_text_label.text="Sent"
		
		
		
func recieve_scores() -> void:
	current_request_type=REQUEST_TYPE.GET
	var headers = ["Content-Type: application/json"]
	var err = http_request.request(
		"http://127.0.0.1:8080/score",
		headers,
		HTTPClient.METHOD_GET,
		"")
	
	
	if err != OK:
		print("ruh roh raggy")
		rich_text_label.text="ruh rog raggy"
	else:
		rich_text_label.text="recieved"
