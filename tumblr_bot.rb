require 'watir'
require 'watir-webdriver'
require './account_info.rb'

#$tpass and $temail are defined in external 'account_info.rb' file.

$root = "http://www.tumblr.com"

#Start browser and sign-in
@browser = Watir::Browser.new
@browser.goto $root+'/login'

@browser.text_field(:name => "user[password]").set($tpass) #Password
@browser.text_field(:name => "user[email]").set($temail) #Email
@browser.button(:id => "signup_forms_submit").click #Click


def find_current_blog
  sleep 1 until @browser.a(:class => 'currently_selected_blog').exists?
  @blogname = @browser.a(:class => 'currently_selected_blog').text
  print_name = "## Current blog is #{@blogname.upcase} ##"
   print_name.length.times { print "#" }
   puts "\n" + print_name + "\n"
   print_name.length.times { print "#" }
   puts "\n\n"
end

# Follows back blogs who are following you
 def autofollow
  find_current_blog
  @browser.goto $root+'/blog/'+ @blogname +'/followers'
   if @browser.button(:class => "chrome blue big follow_button").exists?
     follow_links = @browser.buttons(:class => "follow_button")
   end
  follow_links.each { |follow_button| follow_button.click } if follow_links
  sleep 2
 end

#Reblog random post on the CURRENT page.
def reblog(set_tags)
  reblog_links = []
  @browser.links.each do |link|
    href = link.href
    if href.include? "/reblog"
      reblog_links << link
    end
  end

  #Selects random post on page and begins reblog
  @browser.goto reblog_links[rand(reblog_links.count)].href
  
  #Find post content frame
  content_posts = []
  @browser.iframes.each do |iframe|
    content_posts << iframe if iframe.id.include? "post_"
  end
  
  #Testing - shouldn't typically occur
  puts "!!content_posts.count > 1!!" if content_posts.count > 1
  
  # Find possible tags from <p>'s inside content post if text exists
  # Will not currently catch listed items(specifically, anything not in a paragraph element)
  if content_posts != []
	  tag_ammo = []
	  tag_master = []
	  content_posts[0].ps.each { |p| tag_ammo << p.text }
	  tag_ammo.delete("")
	  
	  #Remove non-letter characters
	  tag_string = tag_ammo.to_s.gsub(/\W+/, ' ')
	  tag_master = tag_string.split
	  
	  #Downcase all potential tags and remove small words
	  tag_master.each do |tag|
		tag.downcase!
		tag_master.delete(tag) if tag.length < 5
	  end
	   puts "## Possible tags found:\n" + tag_master.join(", ") + "\n\n" if tag_master

	  
	  #Establish up to X random tags from the tag selections above
	  rand_tags = []
	  2.times do 
	    rand_tag = tag_master[rand(tag_master.count)]
	    rand_tags << rand_tag if rand_tag!= rand_tags[0]
	  end
	   puts "## Random tags selected:\n" + rand_tags.join(", ") + "\n\n" if rand_tags
	  
	  
	  #Add commas and combine tags sets
	  all_tags = set_tags + rand_tags
	  all_tags = all_tags.join(", ") + ","
	  puts "## All tags added to post:\n" + all_tags + "\n\n"
  else
	#If no text content is present on the post, just pull in tags from function args
	all_tags = set_tags
  end
  
  #Sets tags on form
  @browser.text_field(:class => "editor borderless").set all_tags
  
  #Clicks reblog button to finalize post
  @browser.button(:class => "create_post_button").click
  sleep 4
  @browser.goto $root+'/dashboard'
 end

def tagged_as(tag_arr)
  tag = tag_arr[rand(tag_arr.count)]
  @browser.goto $root + '/tagged/' + tag
end
 
def logout
  @browser.goto $root+'/logout'
  @browser.close
  puts "\n That's all, folks! \n"
end


#Define tags
@search_tags = ['science', 'astronomy', 'astronauts', 'biology'] #add tags which will potentially be searched
@post_tags = ['science', 'cool'] #tags which will be added to reblogged post


#Start method calls
autofollow
tagged_as(@search_tags)
reblog(@post_tags)
logout


   
 ################################################
 ### https://github.com/bananatron/tumblr-bot ###
 ################################################
