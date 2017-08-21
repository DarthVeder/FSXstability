"""
Logger setup. Allows printing to std and to file with different formt.

Usage :
    log_file_name : specify a log name. It will be created in the same directory where the code is called

    To instantiate a new logger simply use:
    logger_new = logging.getLogger(logger_name)

    To log use one of the following:
    logger_new.debug(msg)
    logger_new.info(msg)
    logger_new.warning(msg)
    logger_new.error(msg) : the code will not stop. Use sys.exit(1) if code must be interrupted.
    logger_new.critical(msg)
"""
import logging

log_file_name = 'myapp.log'

# set up logging to file
logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(name)-12s %(funcName)-12s %(levelname)-8s %(message)s',
                    datefmt='%d/%m %H:%M:%S',
                    filename=log_file_name,
                    filemode='w')
# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.StreamHandler()
console.setLevel(logging.INFO)
# set a format which is simpler for console use
formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
# tell the handler to use this format
console.setFormatter(formatter)
# add the handler to the root logger
logging.getLogger('').addHandler(console)

# Now, we can log to the root logger, or any other logger. First the root...
logging.info('Starting the program')

# Now, define loggers which might represent areas in your application:

logger1 = logging.getLogger('myapp.readers')
