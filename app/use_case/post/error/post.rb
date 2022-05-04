require_relative '../../error/use_case'

module UseCase
  class PostUseCaseError < UseCaseError
  end

  class NoSuchPostError < PostUseCaseError
  end
end
