# -*- coding: utf-8 -*-
class OperaWatir::Browser
  include OperaWatir::Deprecation

  attr_accessor :driver, :active_window, :preferences, :keys, :spatnav

  def self.settings=(settings={})
    @opera_driver_settings = nil  # Bust cache
    @settings = settings
  end

  def self.settings
    @settings || self.settings = {}
  end

  # Constructs a new OperaDriver::Browser object.
  #
  # @example
  #   browser = OperaWatir::Browser.new
  #
  # @return [Object] OperaWatir::Browser class.
  def initialize
    OperaWatir.compatibility! unless OperaWatir.api >= 2

    self.driver        = OperaDriver.new(self.class.opera_driver_settings)
    self.active_window = OperaWatir::Window.new(self)
    self.preferences   = OperaWatir::Preferences.new(self)
    self.keys          = OperaWatir::Keys.new(self)
    self.spatnav       = OperaWatir::Spatnav.new(self)
  end

  # Get the name of the browser currently being run.
  #
  # @return [String] Name of browser currently used.
  def name
    'Opera'
  end

  def url=(url)
    active_window.url = url
  end
  alias_method :url, :url=

  # Tells you whether the browser object exists.  Note that this is
  # not the same as checking whether the object is connected to a
  # browser.
  #
  # @return [Boolean] Whether Browser object exists.
  def exists?
    true
  end

  # Query to see if the browser instance is still connected.
  #
  # @return [Boolean] Whether driver is still connected to browser
  #   instance.
  def connected?
    driver.isConnected
  end

  # Instruct the browser instance to quit and shut down.
  def quit
    driver.shutdown
  end

  # Closes all windows.
  #
  # TODO This should be on Windows
  def close_all
    driver.closeAll
  end

  # Get the version number of the driver.  This _is not_ the same as
  # the version number for OperaWatir, which can be retrieved using
  # +OperaWatir.version+ instead.
  #
  # @return [String] Driver version.
  def version
    driver.getOperaDriverVersion
  end

  # Get process identifier for spawned Opera browser instance.  This
  # will only work if instance was started through OperaWatir.
  #
  # @return [Integer] The process ID of the browser instance.
  def pid
    driver.getPid
  end

  # Get the target device's platform.  This is not equivalent of the
  # platform the OperaWatir server might be running on.
  #
  # @return [String] Operating system flavour of the device we're
  #   testing on.
  def platform
    driver.getPlatform
  end

  # Get the full path to the attached browser binary.
  #
  # @return [String] Path to the attached browser's binary.
  def path
    driver.getPath
  end

  # Fetches the user agent (UA) string the browser currently uses.
  #
  # @return [String] User agent string.
  def ua_string
    driver.getUaString
  end

  # Is attached browser instance of type internal build or public
  # desktop?
  #
  # @return [Boolean] True if browser attached is of type desktop,
  #   false otherwise.
  def desktop?
    false  # FIXME
  end

  # Sends an Opera action to the browser.
  #
  # @param  [String] Name of the action.
  # @return [String] Optional return from the performed action.
  def opera_action(name, *args)
    deprecation 'Browser#opera_action is deprecated as of v0.4', 'Use a standard API call instead'
    driver.operaAction(name, param.to_java(:string))
  end

  # Full list of available Opera actions in the Opera build you're
  # using.  Note that this list varies from configuration to
  # configuration, and from build to build.  The Opera actions
  # available to devices-type builds will vary greatly from those
  # available to desktop-types.
  #
  # @return [String] List of available Opera actions.
  def opera_action_list
    deprecation 'Browser#opera_action_list is deprecated as of v0.4', 'Use a standard API call instead'
    driver.getOperaActionList.to_s
  end

  # Selects all content in the currently focused element. Equivalent
  # to pressing Ctrl-A in a desktop browser. To select content in
  # a <textarea> or an <input> field, remember to click it first.
  def select_all
    driver.operaAction('Select all')
  end

  # Copies the currently selected content to the clipboard.
  # Equivalent to pressing Ctrl-C in a desktop browser.
  def copy

    # FIXME: #copy, #cut and #paste really shouldn't use platform-
    # dependent keypresses like this.  But until DSK-327491 is fixed,
    # this will have to do.
    if OperaWatir::Platform.os == :macosx
      keys.send [:command, 'c']
    else
      keys.send [:control, 'c']
    end
  end

  # Cuts the currently selected content to the clipboard.  Equivalent
  # to pressing C-x in a desktop browser.
  def cut
    if OperaWatir::Platform.os == :macosx
      keys.send [:command, 'x']
    else
      keys.send [:control, 'x']
    end
  end

  # Pastes content from the clipboard into the currently focused
  # element.  Equivalent to pressing C-v in a desktop browser.  To
  # paste content into textarea or input fields, remember to click it
  # first.
  def paste
    if OperaWatir::Platform.os == :macosx
      keys.send [:command, 'v']
    else
      keys.send [:control, 'v']
    end
  end

private

  def self.opera_driver_settings
    @opera_driver_settings ||= OperaDriverSettings.new.tap {|s|
      s.setRunOperaLauncherFromOperaDriver true
      s.setOperaLauncherBinary self.settings[:launcher] if self.settings[:launcher]
      s.setOperaBinaryLocation self.settings[:path] if self.settings[:path]
      s.setOperaBinaryArguments self.settings[:args].to_s + ' opera:debug' #+ ' -watirtest'
    }
  end

end
