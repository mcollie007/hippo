module Hippo::Segments
  class IEA < Base

    segment_identifier  'IEA'

    field   :name                 => 'NumberOfIncludedFunctionalGroups',
            :sequence             => 1,
            :datatype             => :string,
            :minimum              => 1,
            :maximum              => 5,
            :required             => true,
            :data_element_number  => 'I16'

    field   :name                 => 'InterchangeControlNumber',
            :sequence             => 2,
            :datatype             => :string,
            :minimum              => 9,
            :maximum              => 9,
            :required             => true,
            :data_element_number  => 'I12'

  end
end
