require 'json'
require 'date'

data = JSON.parse(File.read('osadasami.json'))
notes = []

def children(item, content, level=0)
	if level >= 1
		content = roam_format("#{content}\n#{"\t" * level}- #{item['string']}")
	end

	if item['children']
		level += 1
		item['children'].each do |child|
			content = children(child, content, level)
		end
	end

	content
end

def roam_format(str)
	str
		.gsub('{{[[DONE]]}}', '[x]')
		.gsub('{{[[TODO]]}}', '[ ]')
end

data.each_with_index do |page, page_i|
	puts "#{page['title']}"

	page['children'] && page['children'].each_with_index do |first_child, child_i|
		first_child['create-time'] ||= (page['children'][child_i-1]['create-time'] || page['create-time']) + 1
		date = DateTime.strptime(first_child['create-time'].to_s, '%Q')
		zetteldate = date.strftime('%Y%m%d%H%M%S%L')
		date_tag = "#diary/#{date.year}/#{date.strftime('%m')}/#{date.strftime('%d')}"
		content = "#{date_tag}\n\n#{roam_format(first_child['string'])}"

		content = children(first_child, content)
		filename = page['title'].include?('20') ? zetteldate : page['title']

		notes.push({
			filename: filename,
			content: content
		})
	end
end

notes.each_with_index do |note, i|
	puts "#{i+1}/#{notes.size}"

	if File.exist?("notes/#{note[:filename]}")
		puts "========= EXIST!"
		return
	else
		File.write("notes/#{note[:filename]}.md", note[:content])
	end
end