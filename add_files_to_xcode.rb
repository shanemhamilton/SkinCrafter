#!/usr/bin/env ruby

require 'xcodeproj'

# Open the project
project_path = 'SkinCrafter.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.find { |t| t.name == 'SkinCrafter' }

# Get the main group
main_group = project.main_group['SkinCrafter']

# Files to add
new_files = [
  'Views/TestPaintView.swift',
  'Components/Paintable3DPreview.swift',
  'Views/ModeSelectorView.swift',
  'Views/StudioModeView.swift',
  'Views/SettingsView.swift'
]

# Add each file
new_files.each do |filename|
  file_path = "SkinCrafter/#{filename}"
  
  # Check if file exists
  if File.exist?(file_path)
    # Extract directory and basename
    dir_name = File.dirname(filename)
    base_name = File.basename(filename)
    
    # Find or create the appropriate group
    target_group = main_group
    if dir_name != '.'
      target_group = main_group.groups.find { |g| g.name == dir_name } || main_group.new_group(dir_name)
    end
    
    # Check if already in project
    existing = target_group.files.find { |f| f.path == base_name }
    
    unless existing
      # Add file reference with proper path
      file_ref = target_group.new_file(file_path)
      file_ref.path = filename  # Set the relative path correctly
      
      # Add to build phase
      target.source_build_phase.add_file_reference(file_ref)
      
      puts "Added #{filename} to project"
    else
      puts "#{filename} already in project"
    end
  else
    puts "Warning: #{file_path} not found"
  end
end

# Save the project
project.save

puts "Project updated successfully!"