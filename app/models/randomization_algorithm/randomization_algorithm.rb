module RandomizationAlgorithm

  DEFAULT_CLASS = RandomizationAlgorithm::Algorithms::Default
  ALGORITHM_CLASSES = {
    'permuted-block' => RandomizationAlgorithm::Algorithms::PermutedBlock,
    'minimization' => RandomizationAlgorithm::Algorithms::Minimization
  }

  def self.for(object)
    (ALGORITHM_CLASSES[object.algorithm] || DEFAULT_CLASS).new(object)
  end

end
