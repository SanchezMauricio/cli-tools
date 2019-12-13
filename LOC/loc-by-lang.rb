#!/usr/bin/ruby
############################################
# Copyright (c) 2018-2019 Mauricio Sánchez #
############################################
#
# Pass top-level directories as arguments to get raw LOC by languages
#
# TODO: Enhance to ignore comments and blank lines and or commenst


suffixes = {
            '.bin'       => 'binary',
            '.c'         => 'C/C++',
            '.cc'        => 'C/C++',
            '.cfg'       => 'config',
            '.check'     => 'binary-data',
            '.class'     => 'binary-java',
            '.co'        => 'binary-data',
            '.conf'      => 'config',
            '.cpp'       => 'C/C++',
            '.crt'       => 'certificate',
            '.css'       => 'CSS',
            '.der'       => 'certificate',
            '.expect'    => 'expect',
            '.gawk'      => 'gawk',
            '.gif'       => 'binary-image',
            '.gitignore' => 'config',
            '.go'        => 'Golang',
            '.gpg'       => 'certificate',
            '.gz'        => 'gzip',
            '.h'         => 'C/C++',
            '.html'      => 'HTML',
            '.hpp'       => 'C/C++',
            '.i'         => 'C/C++',
            '.in'        => 'in?',
            '.ipp'       => 'C/C++',
            '.j2'        => 'Ansible',
            '.jar'       => 'tar',
            '.java'      => 'Java',
            '.jpg'       => 'binary-image',
            '.js'        => 'JavaScript',
            '.json'      => 'JSON',
            '.jsp'       => 'JSP',
            '.key'       => 'certificate',
            '.less'      => 'CSS',
            '.log'       => 'log',
            '.lua'       => 'LUA',
            '.md'        => 'docs-or-bundles',
            '.meta'      => 'bundles',
            '.p'         => 'C/C++',
            '.p7b'       => 'certificate',
            '.pem'       => 'certificate',
            '.pl'        => 'Perl',
            '.pm'        => 'Perl',
            '.pdf'       => 'PDF',
            '.png'       => 'binary-image',
            '.pub'       => 'certificate',
            '.py'        => 'Python',
            '.rb'        => 'Ruby',
            '.rnc'       => 'RNC',
            '.sh'        => 'Shell',
            '.svg'       => 'binary-image',
            '.tar'       => 'tar',
            '.txt'       => 'text',
            '.xml'       => 'XML',
            '.xsd'       => 'XML',
            '.xsl'       => 'XML',
            '.yaml'      => 'YAML',
            '.yml'       => 'YAML',
            'Makefile'   => 'Make',
            'Makefile.am' => 'Make',
            'Rakefile'   => 'Ruby',
           }

unless ARGV.count >= 1
  print "Usage: #{$0} <top-level-dir> [<top-level-dir> ...]\n"
  exit 1
end

file_count = Hash.new
line_count = Hash.new

ARGV.each do |dir|

files = `find #{dir} -type f`.split("\n")

files.each do |file|
  suffix_found = nil
  suffixes.keys.each do |suffix|
    if file.match(/#{suffix}$/)
      suffix_found = suffix
      break
    end
  end
  if suffix_found
    lang = suffixes[suffix_found]
    if file_count.key?(lang)
      file_count[lang] += 1
      line_count[lang] += File.readlines(file).count
    else
      file_count[lang] = 1
      line_count[lang] = File.readlines(file).count
    end
  else
    begin
      if first_line = File.readlines(file).first
        lang = nil
        if match = first_line.match(/#! *.*\/([a-zA-z]*)/)
          if match[1] == 'env'
            match = first_line.match(/#! *.*\/([a-zA-z]*)  *([a-zA-Z]*)/)
            lang = match[2]
          else
            lang = match[1]
          end
          lang = 'shell' if lang == 'bash'
          lang = 'Python' if lang == 'python'
          lang = 'Ruby' if lang == 'ruby'
          lang = 'shell' if lang == 'sh'
          if file_count.key?(lang)
            file_count[lang] += 1
            line_count[lang] += File.readlines(file).count
          else
            file_count[lang] = 1
            line_count[lang] = File.readlines(file).count
          end
        else
          file_type = `file #{file}`
          if file_type.match(/(ASCII text|UTF-8 Unicode text)/)
            lang = 'config'
          else
            print "Unknown file type: #{file}\n"
          end
        end
      end
    rescue
      true
    end
  end
end
end

print "\n\n"
printf("%15s   %5s   %9s\n", "Language", "files", "lines")
printf("%15s   %5s   %9s\n", "--------", "-----", "-----")
file_count.keys.sort.each do |lang|
  printf("%15s   %5i   %9i\n", lang, file_count[lang], line_count[lang])
end
