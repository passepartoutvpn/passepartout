def xcconfig_set(path, key, value)
  unless File.exist?(path)
    raise "File not found: #{path}"
  end
  content = File.read(path)
  pattern = /^(#{key}) = .*$/
  replacement = "\\1 = #{value}"
  modified_content = content.gsub(pattern, replacement)
  File.write(path, modified_content)
end

def xcconfig_get(path, key)
  unless File.exist?(path)
    raise "File not found: #{path}"
  end
  pattern = /^#{key} = (.*)$/
  File.foreach(path) do |line|
    if (match = line.match(pattern))
      return match[1]
    end
  end
  nil
end
