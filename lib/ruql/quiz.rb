class Quiz
  @@quizzes = []
  @@yaml_file = nil
  @quiz_yaml = {}
  def self.quizzes ; @@quizzes ;  end
  @@default_options =

    {
    :open_time => Time.now,
    :soft_close_time => Time.now + 24*60*60,
    :hard_close_time => Time.now + 24*60*60,
    :maximum_submissions => 1,
    :duration => 3600,
    :retry_delay => 600,
    :parameters =>  {
      :show_explanations => {
        :question => 'before_soft_close_time',
        :option => 'before_soft_close_time',
        :score => 'before_soft_close_time',
      }
    },
    :maximum_score => 1,
  }

  attr_reader :renderer
  attr_reader :questions
  attr_reader :options
  attr_reader :output
  attr_reader :seed
  attr_reader :logger
  attr_accessor :title, :quizzes

  def initialize(title, yaml, options={})
    @output = ''
    @questions = options[:questions] || []
    @title = title
    @options = @@default_options.merge(options)
    @seed = srand
    @logger = Logger.new(STDERR)
    @logger.level = Logger.const_get (options.delete('l') ||
                                      options.delete('log') || 'warn').upcase
    @quiz_yaml = yaml
  end

  def self.nuke_from_orbit
    @@quizzes = []
  end

  def self.get_renderer(renderer)
    Object.const_get(renderer.to_s + 'Renderer') rescue nil
  end

  def render_with(renderer,options={})
    srand @seed
    @renderer = Quiz.get_renderer(renderer).send(:new,self,options)
    @renderer.render_quiz
    @output = @renderer.output
  end

  def self.set_yaml_file(file)
    @@yaml_file = file &&  YAML::load_file(file)
  end

  def points ; questions.map(&:points).inject { |sum,points| sum + points } ; end

  def num_questions ; questions.length ; end

  def random_seed(num)
    @seed = num.to_i
  end

  # this should really be done using mixins.
  def choice_answer(*args, &block)
    if args.first.is_a?(Hash) # no question text
      q = MultipleChoice.new('',*args)
    else
      text = args.shift
      q = MultipleChoice.new(text, *args)
    end
    q.instance_eval(&block)
    @questions << q
  end

  def select_multiple(*args, &block)
    if args.first.is_a?(Hash) # no question text
      q = SelectMultiple.new('', *args)
    else
      text = args.shift
      q = SelectMultiple.new(text, *args)
    end
    q.instance_eval(&block)
    @questions << q
  end

  def truefalse(*args)
    q = TrueFalse.new(*args)
    @questions << q
  end

  def dropdown(*args, &block)
    q = Dropdown.new(*args)
    q.instance_eval(&block)
    @questions << q
  end
  
  def open_assessment(*args, &block)
    q = get_open_assessment(*args, &block)
    @questions << q
  end

  def simple_open_assessment(*args, &block)
    q = get_open_assessment(*args, &block)
    q.add_simple_question
    @questions << q
  end

  def get_open_assessment(*args, &block)
    y = @quiz_yaml.shift
    raise "Cannot continue - You must have a yaml block for each peer evaluation question" if y.nil?
    yaml = y[1][0]
    q = OpenAssessment.new(*args, yaml)
    q.instance_eval(&block)
    q
  end

  def fill_in(*args, &block)
    if args.first.is_a?(Hash) # no question text
      q = FillIn.new('', *args)
    else
      text = args.shift
      q = FillIn.new(text, *args)
    end
    q.instance_eval(&block)
    @questions << q
  end

  def self.quiz(*args, &block)
    quiz = Quiz.new(*args, (@@yaml_file.shift if @@yaml_file))
    quiz.instance_eval(&block)
    @@quizzes << quiz
  end
end
