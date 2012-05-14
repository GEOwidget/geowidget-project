#!/usr/bin/env ruby

require 'pathname'
require 'ftools'

class ToGettext
    
    def update
        # create / update new root .pot file
        self.update_po
        self.update_translation_pot
    end

    def update_po
        tmpFiles = []
        if ARGV.length == 0
            ARGV[0] = "as"
            ARGV[1] = "mxml"
        end
        # create intermediate files for parsing with gettext
        ARGV.each { |fileType|
            Dir[@dest+'/src/**/*.'+fileType].each { |path|
                infile = File.new(path, 'r')
                #outfile = File.new(path+".po", 'w')
                tmpFiles.push path#+".po"
                #infile.each { |line|
                    # feed a normal assignment
                    # TODO add parenthesis counting check here
                    # TODO add multiple matches per line
                #    if line =~ /(_\(.*?\))/
                #        outfile.puts $~[1]
                #    end
                #}
                #outfile.close
            }
        }
        
        # write file list
        gettextFileList = self.dest+"gettext_input.list"
        gettext         = File.new(gettextFileList, 'w')
        tmpFiles.each { |path| gettext.puts path }
        gettext.close

        # run gettext
        outputFile      = self.dest+"messages.pot"
        system("xgettext --force-po --msgid-bugs-address=info@geowidget.de --default-domain messages  --from-code=UTF-8 -L Python --keyword=gettext:1 --output='%s' --files-from='%s'"%[outputFile, gettextFileList])
            
        # make sure we enforce UFT-8!
        # TODO

        # cleanup tmp files
        #File.delete gettextFileList
        #tmpFiles.each { |file|
        #    File.delete(file)
        #}
    end

    def update_translation_pot
        if not self.po_exists?
            return
        end   
        Dir[self.dest+"locale/*/LC_MESSAGES/"].each { |path|
            destFile = path+"messages.po"
            srcFile  = self.dest+"messages.pot"
            if not File.exist? path+"messages.po"
                self.create_translation_pot( path.match(/.*?\/locale\/([a-z_]{2})\/.*/)[1] )
            end
            # merge the changes in messages.pot to the pot translator file
            system("msgmerge --force-po --update --backup=off --no-wrap '%s' '%s'"%[destFile, srcFile])
        }
    end

    def po_exists?
        return File.exist?(self.dest+"messages.pot")
    end

    # =============================================================================
    
    def init
        self.create_dir_if_not_exist self.dest+"/translation"
        self.create_dir_if_not_exist self.dest+"locale"
        if not File.exist? self.dest+"locale/en_US"
            self.create_translation_dir("en_US")
        end
    end

    def create_dir_if_not_exist(path)
        if not File.exist? path
            Dir.mkdir path
        end
    end

    def check_4_src_dir
        self.parse_dest_dir
        # check if we are in a flex dir
        if not Dir['*'].member? 'src'
            puts "This not a valid flex / actionscript project folder"
            puts "   'src' Folder doesn't exist"
            puts "    - use the '- d' option to specify another destination folder"
            puts "    - chane to a flex-project folder and systemute the script there"
            help
        end 
    end

    def parse_dest_dir
        ARGV.length.times { |i|
            arg = ARGV[i]
            if arg == "-d" or arg == "--dest"
                @dest = Pathname.new(ARGV[i+1]).realpath.to_s
                # remove these arguments from ARGV
                ARGV.delete_at(i)
                ARGV.delete_at(i+1)
                self.check_dest_dir
                return
            end
        }
        @dest = Pathname.new('.').realpath.to_s
    end

    def dest
        return @dest+"/src/translation/"
    end

    def check_dest_dir
        if not File.exist? self.dest
            puts "Folder '%s' doesn't exist!" % self.dest
            self.help
        elsif not File.directory? self.dest
            puts "Given destination '%s' is a file not a folder!" % self.dest
            self.help
        end
    end

    # =============================================================================
    
    def compile
        Dir[self.dest+"locale/**/messages.po"].each { |file|
            outputFile = File.dirname(file) + "/messages.mo"
            system("msgfmt --strict --use-fuzzy --output='%s' '%s'" % [outputFile, file])
        }
    end

    # =============================================================================
    
    def add
        if ARGV.length == 0
            puts "No language provided. \n use: togettext help"
            help
        elsif !((ARGV[0].length == 2) || (ARGV[0].length == 5))
            puts "'%s' is not a valid language identifier!" % ARGV[0]
            help
        end
        self.create_translation_dir ARGV[0]
        if not self.po_exists?
            puts "messages.pot doesn't exist yet!"
            puts "use 'togettext update' to update the messages.pot and the translation files"
            help
        end
    end

    def create_translation_dir(lang)
        if File.exist? self.dest+"locale/"+lang
            puts "Translation for language='%s' exists already!"%lang
            self.help
        end
        self.create_dir_if_not_exist self.dest+"locale/"+lang
        self.create_dir_if_not_exist self.dest+"locale/"+lang+"/LC_MESSAGES"
        self.create_translation_pot lang
    end

    def create_translation_pot(lang)
        inputFile  = self.dest+"messages.pot"
        outputFile = self.dest+"locale/"+lang+"/LC_MESSAGES/messages.po"
        system("msginit --no-wrap --input='%s' --output='%s'"%[inputFile, outputFile])
    end

    # =============================================================================
    
    def help
        puts
        self.version
        if ARGV.length == 0
            puts
            puts "    Type 'help <subcommand>' for help on a specific subcommand" 
            puts
            puts "    Available sucommands:"
            $subcommands.each { |symbol| puts " "*8+symbol.to_s }
        end
        # TODO add help comments
        exit
    end
    
    # =============================================================================
    
    def version
        puts "togettext a little translation helper for flex apps"
    end
    
    
    # ============================================================================
    def run
        self.check_for_gettext
        self.check_4_src_dir
        @subcommands = [
            :help,
            :init,
            :update,
            :add,
            :compile
        ]
        command =  ARGV.shift
        @subcommands.each{ |symbol|
            if symbol.to_s == command
                self.method(symbol).call
                exit
            end
        }
        # otherwise call the help
        puts "Unknown sucommand "+command.to_s
        puts 
        self.help
    end

    def check_for_gettext
        
    end
end


toGettext = ToGettext.new()
toGettext.run()
