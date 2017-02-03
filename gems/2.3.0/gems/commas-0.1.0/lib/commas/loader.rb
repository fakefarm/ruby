class Loader
  attr_accessor :hashes

  def initialize(file=nil)
    @jots = file
  end

  def tags
    tags = []
    CSV.foreach(@jots, headers: true) do |row|
      tags << row['tag']
    end
    tags.uniq
  end

  def jots
    jots = []
    CSV.foreach(@jots, headers: true) do |row|
      jots << row['jot']
    end
    jots
  end

  def as_hashes
    hashes = []
    CSV.foreach(@jots, headers: true) do |row|
      hashes << row.to_hash
    end
    hashes
  end

  def consolidate_jots
    consolidated, unique_keys = [],[]
    as_hashes.each do |hash|
      if unique_keys.include?(hash['tag'])
        add_jot_to_existing_key(consolidated, hash)
      else
        create_title_with_tag_and_jot(unique_keys, consolidated, hash)
      end
    end
    consolidated
  end

  def publish(clean=nil)

   action = if clean
              'w' # write
            else
              'a' # append
            end

    consolidate_jots.each do |file|
      file_name = file.first[0] + '.md'
      dir = if Dir.exist?('markdown')
              'markdown'
            else
              Dir.mkdir('markdown')
              'markdown'
            end
      file_path = File.join(dir,file_name)
      File.open(file_path, action) do |entry|
        entry.write("# " + file.first[0])
        entry.write("\n\n")
        entries = file[file.first[0]]
        entries.each do |jot|
          entry.write("- " + jot)
          entry.write("\n\n")
        end
      end
    end
    true
  end

private

  def add_jot_to_existing_key(consolidated, hash)
    consolidated.each do |h|
      if h.keys.include?(hash['tag'])
        h.first[1].push(hash['jot'])
      end
    end
  end

  def create_title_with_tag_and_jot(unique_keys, consolidated, hash)
    unique_keys.push(hash['tag'])
    consolidated.push(
      { hash['tag'] => [ hash['jot'] ] }
    )
  end
end
