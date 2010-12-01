#!/usr/bin/ruby
# bad_santa.rb by alhazred (who is probably getting a lump of coal in his stocking this year)
#
# REQUIRED GEMS:
# gem install faker mechanize

require 'rubygems'
require 'faker'
require 'mechanize'
require 'pp'
require 'optparse'

BANNER=<<END_S

                                                    $f  dF   ,
                .,,,...                            :$L ;$  ,dP
            ,!!!!!!!',cd$$$$$e,                 q  4$f,$$,z$"
          ,!!!!!!!',c$$$$$$$$$$$$c              `$o`$$kuC3$$ .zf
        ,!!!!!!!',c$$$$$$P**""**?$c              R$beeF?$$$$$"
      ;!!!!!!!.d$$$$$F j"j$3$bf""?b?e,             '$$$$$$P"
     !!!!!!:  $$$$$$P J,f ,d$$b?$bde`$c          .$k<?????>'$b
     !!!!!!!$$$$F".$$".u$$??P}"""^ ?$$c.       d$$$$$dd$$$$$>
      `!!!!!  ?L e$$ $$$$$P'zee^"$$$$boc"$$,     R$$$$$$$$$$$$
       '!!!   z$$$$$c,"$P'd$$F'zdbeereee$$$$$eu    "??$$$$PF"
Mn      !!   d$$$$$$$$ee z$P",d$$$$$$c?$$$$$$$$C  '!!!::::!!!>
MMM   ,cec, '^$$$$$$$$$c,",e$$C?$$$$$$bc?$$$$$$$k !!!!!!!!!!!!
MMM'.$$$$$$$, ?$$$$$$$$P$$$$$$$bc?T$$$$$$d$$$$$$$ . -.`!!!!!!!
nMM d$$$$$$$F  $$P???",e4$$$$$$$$bcc?$$$$$$$$$$$$ /~:.!!!!!!!!!
n.  "$$$$$$$'   ::,"??e,.-.?$$$$$$$$$$$$$$$$$$$$F.C"m.`!!!!!!!'
M":!:`"""""   :!!!!!!i:."?o. "? ?$$$??$$$"$$F"$P<$$$b/4.`4!!!
: 4!!!!h     <!!!!!!!!!!:  .CL.F'.zeElu. : ?eb o$$$$$$o(#c'`
  '`~!!~.ud !!````'!''``zd$$$$$`d$$$CuuJ" !: 4$$$$$$$$$$c"$c
." !~`z$$$":!!!~`..:i! d$$$$$$$`$$$$FCCJ" !!!: ?$$$$$$$$$b $L
$$"z$$$$$":!!! :!!!!!'4$$$$$$$$`$$$$$" "" !!!!!:`$$$$$$$$$$ "
?o$$$$$$F !!!!!!!!!!! 4$$$$$$$$;?$P": JL \.~!!!!i $$$$P?"l.u-
$$$$$$$$F!!!!!!!!!!!!:'R$$$$$$$E.:! $.$$c3$%:`!!! .l==7Cuec^ <
$$$$$$$$ !!!!!!!!!!!!!i ?$$$$P"<!!! ?$`$$$$N.     Rk`$$$$$$r
$$$$$$$$L`!!!!!!!!!!!!!!! .:::!!!''`   $$$$$$      $c"??"7u+? !
$$$$$$$$$ !!!!!!!!!!!'` :!!''`         '""        .'?b"l.4d$ !!!:
$$$$$$$$$b `!!!'''`.. '''`               ...:::!!!!!! $$$.?$b'!!!>
$$$$$$$$$$$beee@$$$$$$$$        ..:::!!!!!!!!!!!!!!!! 3$$b ?$c`!!!
$$$$$$$$$$$$$$$$$$$$$$$f .::!!!!!!!!!!!!!!!!!!!!!!!!! d$$$$`$$b !!! >3
$$$$$$$$$$$$$$$"d$$bu,,.```''!!!!!!!!!!!!!!!!'''''`,d$$$$$$$F.! ?$$$$$F
$$$$$$$$$$$$$$$ $$$$$$$$$$$bc,,,,,,,,,,,,,,,,ccd$$$$$$$$$$$$ !!f ?$$$$"
 "$$$e$$$$$$$$&'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ !! $P"
    `?$$$$$$$$$$$$$e `""**???$$$$$$$$$$$$$$$$$$$$$$$P***""..:!!'
         "?$$$$$$$$k`!!!!!!;;;;;;::,,,...... ,,,,,;;!!!!!!!!!!
             ""???"" !!!!!!!!!!!!!!!!!!!!!!  !!!!!!!!!!!!!!!!!:
                       !!!!!!!!!!!!!!!!.   `!!!!!!!!!'''!!!!'
                     :i !!!!!!!!!!!!!!!!   .``''`.,uu,,.```.
                     !!!!!!!!!!!!!!!!!~`    d$$$$$$$$$$$$$$$$$>
                    c.`~~~~~!!!!!:..        $$$$$$$$$$$$$$$$$$
                    $$$$$eeeeeeeuuuee$      $$$$$$$$$$$$$$$$$"
                    $$$$$$$$$$$$$$$$$$       """"...........
                    ?$$$$$$$$$$$$$$$P"       '!!!!!!!!!!!!!!
                      .."""""""""".:          !!!!!!!!!!!!!
                     i!!!!!!!!!!!!!'          !!!!!!!!!!!'::
                     :!!!!!!!!!!!!!           !!!!!!!!!!:!!:.
                     !!!!!!!!!!'!!!           . `!!!!!!!!!!!!`...
                     `!!!!!!!! -'``           !!!!!!!!!!!!!!!!!!!!!::
                      !!!!!!!!!i!!!:           `~~~~~```~~~~~~~~~~~~`
                      !!!!!!!!!!!!!!!.
                        ```'!!!!!!!'``::..
                              `!!!!!!!!!!!'


    ++++  bad_santa.rb by alhazred -- HO HO HO XMAS '08 MOTHERFUCKERS! ++++

        GREETZ GO OUT TO 
           Dasher, Dancer, Prancer, Vixen, Comet, Cupid, Donner, Blitzen 
              & of course mah boi Rudolph (NORTH POLE CRIPZ 4 LYFE YO!)

END_S


module BadSanta

	


	def self.parse_cmdline
		options={}
		OptionParser.new do |opts|
			opts.banner = BANNER + "\n" + "Usage: "+$0+" [options] [action]\n" +
		        	      "Examples: "+$0+" -e santa@northpole.com -n \"Saint Nick\" -p localhost:8080 -c 03-666-1234\n"+
				      "          "+$0+" -c 03-666-1234\n"+
				      "          "+$0+" -p localhost:8080 -x\n"	
			opts.separator ""
       			opts.separator "Common options:"
			opts.on("-e", "--email [EMAIL]","Use EMAIL when placing calls, random otherwise") do |email|
				options[:email]=email
			end
			opts.on("-n", "--name [NAME]","Use NAME when placing calls, random otherwise") do |name|
				options[:name]=name
			end
			opts.on("-p", "--proxy [PROXY]","Use http PROXY for all web request, format HOST:PORT") do |proxy|
				options[:proxy]=proxy
			end
			opts.on("-h", "--help","Show this message") do 
				puts opts
				exit
			end

			
			opts.separator ""
                        opts.separator "Actions:"
			opts.on("-c", "--call [NUMBER]","Place a single santa call to NUMBER, non numeric chars are stripped") do |number|
				options[:number]=number.gsub(/[^0-9]/,"").gsub(/^(\d\d)(\d\d\d)(\d\d\d\d)/,'\1 \2 \3') # normalize
				options[:action] = :call
			end
			 opts.on("-x", "--xmas-psychosis","Scrape random numbers from the whitepages and call them USE WITH CAUTION") do 
				options[:action] = :psychosis
			end

			
			opts.parse!
			
			case options[:action]
				when :call then place_call(options[:number],options)
				when :psychosis then xmas_psychosis!(options)
				else puts "ERROR: No action specified!\n\n#{opts}"	
			end
		end
		
	end


	#
	# make santa call 'phone_number', options :num_kids, :name, :email leave blank for random, :proxy => "host:port" for web proxy
	#

	def self.place_call(phone_number,options={})
		begin
 			print "Placing call to #{phone_number} ..."
			STDOUT.flush
			agent = get_web_agent(options[:proxy])
			our_name = Faker::Name.name 
			n_kiddies = options[:num_kids]
			n_kiddies = 1 + rand(3) if n_kiddies.nil?
			page = agent.get('http://www.santacall.co.nz/') # need first page because it supplies form with hidden fields
		
			web_pause

			# populate the form and submit

			cb="_ctl0:ContentPlaceHolder1"
			santa_form = page.form('aspnetForm')
			santa_form["#{cb}:txtName"] =  options[:name].nil? ? Faker::Name.name : options[:name]
			santa_form["#{cb}:txtEmail"] = options[:email].nil? ? Faker::Internet.email : options[:email]

			n_kiddies.times do |index|
				santa_form["#{cb}:txtChildName#{index+1}"] = Faker::Name.first_name
				santa_form["#{cb}:ddlChildAge#{index+1}"] = ((["0 to 2", "3 to 4", "5 to 6","7 to 8"])[rand(4)])
				santa_form["#{cb}:rbGender#{index+1}"] = ((rand(2) == 0) ? "Male" : "Female")
			end

			santa_form["#{cb}:txtPhoneNumber"] = phone_number
			santa_form["#{cb}:btnRequestCall.x"] = rand(200)
			santa_form["#{cb}:btnRequestCall.y"] = rand(200)
			santa_form["#{cb}:chkTerms"]="on"

			page=santa_form.submit
			if page.root.to_html=~/My elves will be dialing/
				puts " OK"
				return true
			else
				puts " FAIL"
				return false
			end
		rescue RuntimeError => exception
			puts " FAIL #{exception}"
			return false
		rescue Net::HTTPClientError => exception
			puts " FAIL #{exception}"
			return false
		end
	end

	def self.xmas_psychosis!(options)
		puts "Entering 666 xmas psychosis mode!!! ^_^ kekekekekeke"
		number_queue=[]
		while true
			while number_queue.empty?
				number_queue=scrape_whitepages
			end
			victim=number_queue.pop
			place_call(victim,options)
			pause=30+rand(30)
			puts "Pausing #{pause} seconds"
			sleep(pause)	
		end
	end

	def self.scrape_whitepages(options={})
		begin
			print "Scraping whitepages ... "
			STDOUT.flush
			agent=get_web_agent(options[:proxy])
			page = agent.get('http://www.whitepages.co.nz/') 
			web_pause
			form=page.forms[1]
			last_name=Faker::Name.last_name
			initial=("A".."Z").to_a[rand(26)]	
			form['what']="#{initial} #{last_name}"
 			print "#{form['what']} ..."
			STDOUT.flush
			page=form.submit
			results=page.root.to_html.scan(/\d\d-\d\d\d \d\d\d\d/)
			puts " #{results.length} #'s found"
			return results
		rescue RuntimeError => exception
			puts " FAIL #{exception}"
			return []
		rescue Net::HTTPClientError => exception
			puts " FAIL #{exception}"
			return []
		end
	end
	
	# get a mechanize agent with random user agent string
	#

	def self.get_web_agent(proxy=nil)
		agent = WWW::Mechanize.new
		unless proxy.nil?
			proxy_host, proxy_port = proxy.split(":")
			agent.set_proxy(proxy_host,proxy_port)
		end
		agent.user_agent_alias=WWW::Mechanize::AGENT_ALIASES.keys[rand(WWW::Mechanize::AGENT_ALIASES.length-1)]
		return agent
	end

	#
	# pause execution for a reasonable amount of time
	#

	def self.web_pause
		seconds=sleep(1+rand(5))
		sleep(seconds)
	end

end

BadSanta::parse_cmdline

#pp BadSanta::scrape_whitepages
		
	
 
	








