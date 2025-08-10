require "rails_helper"

RSpec.describe "Locale files" do # rubocop:disable RSpec/DescribeClass
  describe "duplicate keys detection" do
    def find_duplicate_keys_with_line_numbers(file_path) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      duplicates = {}
      current_path = []
      line_number = 0
      key_occurrences = Hash.new { |h, k| h[k] = [] }

      File.foreach(file_path) do |line|
        line_number += 1

        # Skip empty lines and comments
        next if line.strip.empty? || line.strip.start_with?("#")

        # Calculate indentation level
        line[/\A */].size

        # Parse key-value pairs
        if line =~ /^( *)([^:]+):\s*(.*)/
          spaces = Regexp.last_match(1)
          key = Regexp.last_match(2).strip
          Regexp.last_match(3).strip

          # Handle symbols (keys starting with :)
          key = key.gsub(/^:/, "")

          # Calculate depth based on indentation
          depth = spaces.length / 2

          # Adjust current path based on depth
          current_path = current_path[0...depth]
          current_path << key

          # Build full key path
          full_key = current_path.join(".")

          # Record this occurrence
          key_occurrences[full_key] << {
            line:        line_number,
            content:     line.strip,
            parent_path: current_path[0...-1].join(".")
          }
        end
      end

      # Filter to find only duplicates
      key_occurrences.each do |key, occurrences|
        duplicates[key] = occurrences if occurrences.size > 1
      end

      duplicates
    end

    def format_duplicate_report(file, duplicates)
      return nil if duplicates.empty?

      report = ["File: #{file}"]
      report << ("=" * 80)

      duplicates.each do |key, occurrences|
        report << "\nDuplicate key: '#{key}'"
        report << "Found #{occurrences.size} times:"
        occurrences.each do |occ|
          report << "  Line #{occ[:line]}: #{occ[:content]}"
        end
      end

      report.join("\n")
    end

    # Test each locale file
    Rails.root.glob("config/locales/*.yml").each do |locale_file|
      file_name = File.basename(locale_file)

      it "#{file_name} should not have duplicate keys" do # rubocop:disable RSpec/NoExpectationExample
        duplicates = find_duplicate_keys_with_line_numbers(locale_file)

        if duplicates.any?
          report = format_duplicate_report(locale_file, duplicates)
          raise "Duplicate keys found in #{file_name}:\n\n#{report}\n"
        end
      end

      it "#{file_name} should not mix symbol and string key styles" do # rubocop:disable RSpec/NoExpectationExample
        symbol_keys = []
        line_number = 0

        File.foreach(locale_file) do |line|
          line_number += 1

          # Look for symbol-style keys (starting with :)
          if line =~ /^( *):([^:]+):/
            symbol_keys << {
              line:    line_number,
              content: line.strip,
              key:     Regexp.last_match(2).strip
            }
          end
        end

        if symbol_keys.any?
          report = ["File: #{locale_file}"]
          report << ("=" * 80)
          report << "\nFound symbol-style keys (these can cause override issues):"
          symbol_keys.each do |sk|
            report << "  Line #{sk[:line]}: #{sk[:content]}"
          end

          msg = "Symbol-style keys found in #{file_name}:\n\n#{report.join("\n")}\n\n"
          msg += "These should be converted to string-style keys to avoid conflicts."
          raise msg
        end
      end
    end
  end
end
