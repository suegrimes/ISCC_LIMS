META_TAGS = {:description => "ISCC RNA-Seq provides detailed transcriptome analysis of intestinal stem cell populations for the 
Intestinal Stem Cell Consortium",
             :keywords => ["stanford, rna sequencing, transcriptome, iscc, stem cells, mus musculus, mouse intestinal stem cells"]}

require 'active_record_extension'

version_file = "#{Rails.root}/public/app_versions.txt"

#read App_Versions file to set current application version #
#version# is first row, first column
if FileTest.file?(version_file)
  File.open(version_file) do |file|
    filerow = file.gets
    APP_VERSION = filerow.split(/\t/)[0]
    file.close
  end
end
