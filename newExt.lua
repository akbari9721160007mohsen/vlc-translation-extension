-- "newExt.lua" 

-- Created :  26.08.2018 Thursday 22:26 By Tarik

-------
SUBTITLE_LANG = "en"     --> type code of the subtitle language(en, ru ,tr, de ...).
TRANSLATION_LANG = "tr"  --> type code of the language that you want.
--------------


-------- paste the key that you got from the yandex api.
TRANS_KEY = "trnsl.1.1.20180828T220750Z.faf2fad2d31ce3d2.adf171e2e373e392e3223e07520bce4aa2abcdbb"
--------


---> do not touch here.
LANG_HINTS = SUBTITLE_LANG .. "-" .. TRANSLATION_LANG 
YANDX_URL = "https://translate.yandex.net/api/v1.5/tr.json/translate"

-----

text_duration_long=10
text_duration_short=4

text_position = "top-left"

activated_msg = "Extension Activated, Enjoy!"
wait_msg = "Working, .................wait please!"

function descriptor()
	return {
		title = "Tarik's Translator",
		version = "1.0",
		author = "",
		url = 'http://',
		shortdesc = "Tarik'sss",
		description = "full description",
		capabilities = {"menu", "input-listener", "meta-listener", "playing-listener"}
	}
end

function activate()
	--- Text göster, aktive edildi,,
    vlc.osd.message(activated_msg, channel1, text_position, text_duration_short*1000*1000 )
end
function deactivate()
	-- when deactivated....
end
function close()
	--dialog box kapatılınca çağrılıyor
	vlc.deactivate()
end

function input_changed()
	-- related to capabilities={"input-listener"} in descriptor()
	-- triggered by Start/Stop media input event
end
function playing_changed()
	-- related to capabilities={"playing-listener"} in descriptor()
	-- triggered by Pause/Play madia input event
end
function meta_changed()
	-- related to capabilities={"meta-listener"} in descriptor()
	-- triggered by available media input meta data?
end

function menu()
	-- related to capabilities={"menu"} in descriptor()
	-- menu occurs in VLC menu: View > Extension title > ...
	return {"Translate", "Info"}
end
-- Function triggered when an element from the menu is selected
function trigger_menu(id)
	if(id == 1) then
        --Menu_action1()
        vlc.msg.dbg("[Dummy] Status: " .. "clciked menu:1")
        translate()
    elseif(id == 2) then
        vlc.msg.dbg("[Dummy] Status: " .. "clciked menu:2")
		setings()
	end
end


function translate()
    vlc.osd.message(wait_msg, channel1, text_position, text_duration_short*1000*1000 )    
    log_this("Translate command received,,,working")
    loadwords()
    --get subtitle
end

function settings()
 log_this("action: setings")

 create_dialog()
end

function Info()



end
-- Custom part, Dialog box example: -------------------------

greeting = "Config"  -- example of global variable
function create_dialog()
	w = vlc.dialog("Tarik's Transaltor - Info Box")
	w1 = w:add_text_input("Hello world!", 1, 1, 3, 1)
	w2 = w:add_html(greeting, 1, 2, 3, 1)
	w3 = w:add_button("Action!",click_Action, 1, 3, 1, 1)
	w4 = w:add_button("Clear",click_Clear, 2, 3, 1, 1)
end
function click_Action()
	local input_string = w1:get_text()  -- local variable
	local output_string = w2:get_text() .. input_string .. "<br />"
	--w1:set_text("")
	w2:set_text(output_string)
end
function click_Clear()
	w2:set_text("")
end


function log_this(m)
    vlc.msg.info( "heyy] ".. m )
    vlc.msg.dbg( "[heyy] ".. m )
end

-- To load the words in the subtitle to the list
function loadwords()
    vlc.msg.dbg("[Dummy] Status: " .. "clciked loadwords")
    local input = vlc.object.input()
        local actual_time = vlc.var.get(input, "time")
        actual_time=actual_time/1000000
        local timeAsString = os.date("%H:%M:%S", now_time)
        
        vlc.msg.dbg("[Dummy] actual time: " .. actual_time)        
        if subtitles_path==nil then 
            subtitles_path=media_path("srt") 
        end
        
        -- To name the file based on the type of operating system
        file = io.open("/"..subtitles_path, "r")
        if file==nil then
        file = io.open(subtitles_path, "r")
        vlc.msg.dbg("[Dummy] file" .. "opened")
        end
        if file==nil then
           
            return
        end
        
        while true do
            line = file:read()
            subText = ""
            
            if (line == nil) then 
                break 
            else
                if(line:len() > 1) then
                    if( string.find(line,"%d:%d") ~= nil ) then
                        h1 = string.sub(line, 1, 2)
                        m1 = string.sub(line, 4, 5)
                        s1 = string.sub(line, 7, 8)
                        ms1 = string.sub(line, 10, 12)
                        h2 = string.sub(line, 18, 19)
                        m2 = string.sub(line, 21, 22)
                        s2 = string.sub(line, 24, 25)
                        ms2 = string.sub(line, 27, 29)
                        
                        initial_time = format_time(h1,m1,s1,ms1)
                        final_time = format_time(h2,m2,s2,ms2)
                      --  vlc.msg.dbg("[Dummy] initial time: " .. line)
                      --  vlc.msg.dbg("[Dummy] final time: " .. final_time)
                        line = file:read()
                        
                        while ( line:len() > 1 ) do
                            subText = subText.." "..line
                            line = file:read()
                          --  vlc.msg.dbg("[Dummy] Status: " .. "subtext fetched")
                            if line == nil	then
                                break
                            end 
                        end 
    
                        if line == nil	then
                            break
                        end 
                        
                        -- If the actual time is within the time frame, select the subtitle
                        if(actual_time > initial_time and actual_time < final_time) then
                                words = {}
                              --  vlc.msg.dbg("[Dummy] subtext: " .. "time okeyyy")
                                subText = string.gsub(subText,"<%p*%a*>","")				-- To remove html tags in the subtitles
                                subText = string.lower(subText)
                                
                                                 -- To split the subtitle into words
                                   words[#words+1] = subText
                                   getTranslation(subText)
                            break				
                        end
                    end
                end
            end
        end
        
    end
    
    
    function format_time(h,m,s,ms) -- time to seconds
        
        return tonumber(h)*3600+tonumber(m)*60+tonumber(s)+tonumber("."..ms)
    end
    
    function media_path(extension)
        local media_uri = vlc.input.item():uri()
        media_uri = vlc.strings.decode_uri(media_uri)
        media_uri = string.gsub(media_uri, "^.-///(.*)%..-$","%1")
        media_uri = media_uri.."."..extension
        vlc.msg.info(media_uri)
        return media_uri
    end

    function getTranslation(strrr)
      --  url = "http://translate.google.com/".. "#" .. SOURCE_LANG .. "/" .. TARGET_LANG.. "/" .. vlc.strings.encode_uri_component( strrr ) 
      --url = "http://translate.yandex.ru/tr.json/translate?lang="..SOURCE_LANG.."-"..TARGET_LANG.."&text=".. vlc.strings.encode_uri_component( strrr) .."&srv=tr-text" 
     myText = vlc.strings.encode_uri_component(strrr)
      url = YANDX_URL .. "?key=" .. TRANS_KEY .. "&text=" .. myText   .. "&lang=" .. LANG_HINTS
      vlc.msg.dbg( "[heyy] ".. url )
        

 local GET, error_msg = vlc.stream(url)
 if not GET then
    vlc.osd.message(error_msg, channel1, text_position, text_duration_long*1000*1000 )
     return
 end


 local data_received = ""..GET:readline()
 if not data_received then
        vlc.msg.dbg( "[heyy] ".. "No data received!" )
     return
 end
 if data_received == ""	then
    vlc.msg.dbg( "[heyy] ".. "!null data received" )
    return
end 

local json = require ("dkjson")
string = ""
string = string .. data_received
peo = json.decode(data_received)
-- _log(  data  )
--vlc.msg.dbg( "[heyy] datass : ".. tostring(data) )
 -- TODO: parse multiple sentences
 if ( translator == "google" ) then
     out = string.match( data, "\"([^\"]+)\"-" )
   --  _log(  vlc.strings.from_charset("KOI8-R", out) )
     out = vlc.strings.from_charset("koi8-r", out);
 else
     out = data
 end

 vlc.osd.message( peo.text[1] , channel1, text_position, text_duration_long*1000*1000 )
     
end