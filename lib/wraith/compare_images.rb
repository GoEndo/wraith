require "wraith"
require "wraith/helpers/logger"
require "image_size"
require "open3"
require "parallel"
require "shellwords"

class Wraith::CompareImages
  include Logging
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def compare_images
  	folders = Dir.glob("#{wraith.directory}/*").select {|f| File.directory? f}
  	folders.each do |folder|
	  	bases = []
		files = Dir.glob(folder + "/*.png")
		files.each do |file|
			if file.end_with?('_latest.png')
				file.slice!('_latest')
			end
			
			bases << file unless bases.include?(file)
		end
		
		Parallel.each(bases, :in_processes => Parallel.processor_count) do |base|
		  diff = base.gsub(/.png$/, "_diff.png")
		  info = base.gsub(/.png$/, "_data.txt")
		  compare = base.gsub(/.png$/, "_latest.png")
		  logger.info "Comparing #{base} and #{compare}"
		  compare_task(base, compare, diff, info)
	   	end
    end
  end

  def percentage(img_size, px_value, info)
    pixel_count = (px_value / img_size) * 100
    rounded = pixel_count.round(2)
    File.open(info, "w") { |file| file.write(rounded) }
  end

  def compare_task(base, compare, output, info)
    cmdline = "compare -fuzz #{wraith.fuzz} -metric AE -highlight-color #{wraith.highlight_color} #{base} #{compare.shellescape} #{output}"
    px_value = Open3.popen3(cmdline) { |_stdin, _stdout, stderr, _wait_thr| stderr.read }.to_f
    begin
      img_size = ImageSize.path(output).size.inject(:*)
      percentage(img_size, px_value, info)
    rescue
      File.open(info, "w") { |file| file.write("invalid") } unless File.exist?(output)
    end
  end
end
