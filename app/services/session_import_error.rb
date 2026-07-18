# Domain-specific errors for the background Session import pipeline.
#
# Raising dedicated classes — instead of a bare RuntimeError, or letting
# Mongoid's generic Mongoid::Errors::Validations ("Races is invalid") bubble up
# - lets SessionImportJob store a clear, admin-facing message while keeping the
# technical backtrace, and lets callers tell apart "the file wasn't a valid log"
# from "the parsed data failed validation".
class SessionImportError < StandardError; end

# The uploaded file could not be parsed as a Re-Volt session log at all
# (wrong shape, unreadable, missing the expected rows/columns, ...).
class SessionImportError::MalformedLog < SessionImportError; end

# The log parsed, but the resulting Session — or one of its embedded races /
# racers / result rows — failed model validation. The message carries a
# per-field breakdown naming exactly what is wrong and where.
class SessionImportError::InvalidSession < SessionImportError; end
