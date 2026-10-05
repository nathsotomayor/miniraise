# Usage: ruby script/export_slice.rb <base_commit> <slice_number>
# Exports the files a slice added or modified, from HEAD, for manual upload.
require "fileutils"
require "open3"

SECRET_PATTERNS = [ "*.key", ".env*", "*.sqlite3" ].freeze
LOCAL_DIRS = %w[node_modules log tmp storage].freeze

def git(*args)
  output, status = Open3.capture2("git", *args)
  abort "git #{args.join(" ")} failed" unless status.success?
  output
end

# Rails ships empty .keep placeholders inside log/, tmp/ and storage/; they hold no local data.
def blocked?(path)
  return false if File.basename(path) == ".keep"

  name = File.basename(path)
  return true if SECRET_PATTERNS.any? { |pattern| File.fnmatch?(pattern, name, File::FNM_DOTMATCH) }

  path.split("/").any? { |segment| LOCAL_DIRS.include?(segment) }
end

def section(title, paths)
  [ title, *paths.map { |path| "  #{path}" }, "" ]
end

base, number = ARGV
abort "usage: ruby script/export_slice.rb <base_commit> <slice_number>" unless base && number&.match?(/\A\d+\z/)

Dir.chdir(git("rev-parse", "--show-toplevel").strip)

changes = git("diff", "--name-status", "--no-renames", base, "HEAD").lines.map { |line| line.chomp.split("\t", 2) }
added = changes.select { |status, _| status == "A" }.map(&:last)
modified = changes.select { |status, _| status == "M" }.map(&:last)
deleted = changes.select { |status, _| status == "D" }.map(&:last)
exported = added + modified

blocked_paths = exported.select { |path| blocked?(path) }
abort "Blocked paths, nothing exported:\n  #{blocked_paths.join("\n  ")}" if blocked_paths.any?

out_dir = File.join("export", "slice-#{number}")
FileUtils.rm_rf(out_dir)
FileUtils.mkdir_p(out_dir)
exported.each do |path|
  target = File.join(out_dir, path)
  FileUtils.mkdir_p(File.dirname(target))
  File.binwrite(target, git("show", "HEAD:#{path}"))
end

dot_paths = exported.select { |path| path.split("/").any? { |segment| segment.start_with?(".") } }

head = git("rev-parse", "HEAD").strip
report = [ "Slice #{number} export (base #{base}, HEAD #{head})", "" ]
report += section("Added (#{added.size}):", added)
report += section("Modified (#{modified.size}):", modified)
report += section("Deleted (#{deleted.size}, not exported; remove these by hand on GitHub):", deleted)
report += [ "Total exported files: #{exported.size}", "" ]
report += section("Paths with a dot segment (GitHub web upload hides these):", dot_paths)

report_path = File.join("export", "slice-#{number}-report.txt")
File.write(report_path, report.join("\n") + "\n")
puts report.join("\n")
puts "\nWritten: #{out_dir}/ and #{report_path}"
