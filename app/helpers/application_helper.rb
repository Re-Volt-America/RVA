module ApplicationHelper
  def is_production?
    Rails.env == 'production' || Rails.env == 'staging'
  end

  def meta(tag, text)
    content_for :"meta_#{tag}", text
  end

  def yield_meta_tag(tag, default_text = '')
    content_for?(:"meta_#{tag}") ? content_for(:"meta_#{tag}") : default_text
  end

  # Check if the passed user is an admin
  # @return [Boolean] true if the current user is an admin, false otherwise
  def user_is_admin?(user = current_user)
    user&.admin?
  end

  # Check if the passed user is a moderator
  # @return [Boolean] true if the current user is a moderator, false otherwise
  def user_is_mod?(user = current_user)
    user&.mod?
  end

  # Check if the passed user is an organizer
  # @return [Boolean] true if the current user is an organizer, false otherwise
  def user_is_organizer?(user = current_user)
    user&.organizer?
  end

  # Check if the passed user has a staff role
  # @return [Boolean] true if the current user either an admin, a mod or an organizer
  def user_is_staff?(user = current_user)
    user && (user.admin? || user.mod? || user.organizer?)
  end

  # Check whether the passed object evaluates to a true expression
  # @param obj [Object]
  # @return true if the object can be evaluated to "true"
  def true?(obj)
    obj.to_s.downcase == 'true' || obj.to_s.downcase == '1'
  end

  # @param datetime [DateTime]
  # @return [String] Pretty date string (i.e: April 21st, 2022)
  def pretty_datetime(datetime)
    datetime.strftime("%B #{datetime.day.ordinalize}, %Y")
  end

  # @param datetime [DateTime]
  # @return [String] Precise pretty date string (i.e: April 21st, 2022 - 06:32 AM)
  def pretty_time_precise(datetime)
    datetime.strftime("%B #{datetime.day.ordinalize}, %Y - %H:%M %p")
  end

  # @param session [Session]
  # @return [String] Hex colour of the session category
  def session_color_hex(session)
    return nil unless session.is_a?(Session)

    SYS::RVA_CATEGORY_COLORS[session.category]
  end

  # @param session [Session]
  # @return [String] Capitalised name of the session category
  def session_category_name(session)
    return nil unless session.is_a?(Session)

    category_name(session.category)
  end

  # @param category [Integer]
  # @return [String] Capitalised name of the category
  def category_name(category)
    SYS::RVA_CATEGORY_NAMES[category].capitalize.gsub(/-[a-z]/, &:upcase)
  end

  # @param input [Number] The number
  # @param value [Integer] Amount of precision
  # @return [String] The number with the desired precision as a string
  def precision(input, value = 0)
    ("%.#{value}f" % input)
  end

  def count_all(array, values_to_count)
    array.count { |el| values_to_count.include?(el) }
  end

  def ordinal_ending(n)
    case n % 100
    when 11, 12, 13 then 'th'
    else
      case n % 10
      when 1 then 'st'
      when 2 then 'nd'
      when 3 then 'rd'
      else 'th'
      end
    end
  end

  # @param content [String] Content
  # @return [String] Parsed html and/or markdown text
  def render_pretty(content, config = Sanitize::Config::RELAXED)
    Sanitize.clean(content, config)

    options = { :input => 'Kramdown', :parse_block_html => true }
    Kramdown::Document.new(content, options).to_html.html_safe
  end

  # Truncates a string to a set amount of characters. The finalising character is an ellipsis by default. If the string
  # is shorter than the max, then it will effectively return itself.
  # @param string [String] The original string
  # @param max_length [Integer] The length to which we will truncate to
  # @param final_char [String] The string to append at the end of the truncated string, if truncated at all
  def truncate_string(string, max_length, final_char = '...')
    longer = string.length > max_length
    string = string[0..max_length]
    string += final_char if longer

    string
  end

  # Converts a colour in hex format into its opposite colour in the spectrum.
  # @param hex [String] Colour in hex format (e.g. #2e2e2e)
  # @param black_white [Boolean] True to convert the resulting colour into black or white depending on which side of
  # the spectrum it's the closest to. False to just return the inverted colour hex.
  # @return [String] Hex string representing the inverse equivalent of colour 'hex'
  def invert_color(hex, black_white = false)
    return hex unless hex =~ SYS::VALID_HEX_FORMAT

    red, green, blue = hex.match(SYS::RGB_REGEXP).captures.map(&:hex)

    return (red * 0.299 + green * 0.587 + blue * 0.114) > 186 ? '#000000' : '#FFFFFF' if black_white

    red = (255 - red).to_s(16)
    green = (255 - green).to_s(16)
    blue = (255 - blue).to_s(16)
    ['#', *[red, green, blue].map { |c| c.rjust(2, '0') }].join
  end
end
