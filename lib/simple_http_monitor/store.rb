require 'yaml/store'

module SimpleHttpMonitor
  class Store
    def save(obj, path=nil)
      path = (path || obj.class).to_s
      store.transaction do
        store[path] = obj
      end
    end

    def load(key)
      store.transaction do
        store[key.to_s]
      end
    end

    private

    def initialize(store_dir)
      @store_dir = store_dir
    end

    def store_file
      File.join(@store_dir, 'storage.yml')
    end

    def store
      @store ||= YAML::Store.new(store_file)
    end
  end
end
