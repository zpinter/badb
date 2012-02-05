require 'highline/import'
require 'configliere'
require 'fileutils'

module BADB
  class Runner
        
    CONFIG_FILE = File.expand_path("~/.badb_config.yaml")
    
    def initialize
      read_settings
    end
    
    def read_settings
      Settings.use :config_file
      Settings({
                 :device_history => [],
                 :aliases => {}
               })
      FileUtils.touch(CONFIG_FILE)
      Settings.read(CONFIG_FILE)
    end
    
    def save_settings
      Settings.save!(CONFIG_FILE)
    end
    
    def adb_path
      return @adb_path if @adb_path
      @adb_path = `which adb`.strip
      if @adb_path.empty?
        raise "Can't find your adb command. Is your path set\?"
      end
      @adb_path
    end
    
    def get_devices
      devices = []
      IO.popen("#{adb_path} devices").each_line do |line|
        line = line.strip
        if line =~ /^(.*)\tdevice$/
          devices << $1
        end
      end      
      devices
    end
    
    def choose_device(opt={})
      opt = {
        :all => false,
        :save_choice => true
      }.merge(opt)
      devices = get_devices
      devices = filter_latest_device(devices) if !opt[:all]
      
      if devices.empty?
        raise "No devices attached"
      elsif devices.size == 1
        yield devices[0] if block_given?
      else
        choose do |menu|
          menu.prompt = "Choose your adb device: "
          
          devices.each do |device|
            menu.choice device_label(device) do
              save_choice(device) if opt[:save_choice]
              yield device if block_given?
            end
          end
        end
      end
    end
    
    def save_choice(device)
      hist = Settings[:device_history]
      hist.delete(device)
      hist << device
      Settings[:device_history] = hist
      save_settings
    end
    
    def filter_latest_device(devices)
      hist = Settings[:device_history]
      
      latest_history_device = nil
      latest_history_index = -1
      
      devices.each do |d|
        index = hist.index(d)
        if index && index > latest_history_index
          latest_history_index = index
          latest_history_device = d
        end
      end
      
      return [latest_history_device] if latest_history_device
      devices
    end
    
    def current_device
      devices = get_devices
      devices = filter_latest_device(devices)
      
      return devices[0] if devices.size == 1
      return nil
    end

    def show_current_device
      d = current_device
      
      if d
        puts "Current device is " + device_label(current_device)
      else
        puts "No current device."
      end
    end
    
    def show_help
      puts "badb - Better Android Debug Bridge\n\n"
      puts "Usage:"
      puts "badb choose - choose the current android device to map badb command to, via prompt"
      puts "badb alias - add a friendly name for a specific device, via prompt"
      puts "badb current - the current android device"
      puts "badb list - lists android devices, with aliases, indicating the current one"
      puts "badb help - this message"
      puts "badb adbhelp - the original adb help command"
    end
    
    def device_label(device)
      device_alias = Settings[:aliases][device]
      
      if device_alias
        "#{device} (#{device_alias})"
      else
        device
      end
    end
    
    def create_alias
      puts "Create an alias: "
      
      choose_device(:all => true,:save_choice => false) do |device|
        device_alias = ask("Enter an alias for #{device_label(device)}: ")
        Settings[:aliases][device] = device_alias
        save_settings
      end
    end
    
    def list_devices
      devices = get_devices
      current = current_device
      
      puts "List of devices: "
      devices.each do |d|
        
        if d == current_device
          puts device_label(d) + " #current"
        else
          puts device_label(d)
        end
      end
    end
    
    def run
      if !ARGV.empty?
        if ARGV[0] == "choose"
          choose_device(:all => true)
          return
        elsif ARGV[0] == "current"
          show_current_device
          return
        elsif ARGV[0] == "alias"
          create_alias
          return
        elsif ARGV[0] == "list"
          list_devices
          return
        elsif ARGV[0] == "help"
          show_help
          return
        elsif ARGV[0] == "adbhelp"
          Kernel.exec(adb_path,"help")
          return
        end
      end
      
      choose_device do |device|
        ENV["ANDROID_SERIAL"] = device
        # p [:device, device]
        # p [:cmd, adb_path, ARGV]
        Kernel.exec(adb_path,*ARGV)
      end
    end
  end
end

