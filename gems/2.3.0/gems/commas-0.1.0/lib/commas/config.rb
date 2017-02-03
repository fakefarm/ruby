class Config
  attr_reader :yaml

  def initialize(yaml='config.yml')
    read_yaml(yaml)
  end

  def filepath_csv
    yaml['directories']['csv']
  end

  def filepath_markdown
    yaml['directories']['markdown']
  end

  def read_yaml(file)
    @yaml ||= YAML.load(File.read(file))
  end
end
