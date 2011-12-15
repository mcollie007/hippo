module Hippo::Segments
  class TA1 < Base

    segment_identifier  'TA1'

    field   :name                 => 'InterchangeControlNumber',
            :sequence             => 1,
            :datatype             => :string,
            :minimum              => 9,
            :maximum              => 9,
            :required             => true,
            :data_element_number  => 'I12'

    field   :name                 => 'InterchangeDate',
            :sequence             => 2,
            :datatype             => :string,
            :minimum              => 6,
            :maximum              => 6,
            :required             => true,
            :data_element_number  => 'I08'

    field   :name                 => 'InterchangeTime',
            :sequence             => 3,
            :datatype             => :string,
            :minimum              => 4,
            :maximum              => 4,
            :required             => true,
            :data_element_number  => 'I09'

    field   :name                 => 'InterchangeAcknowledgmentCode',
            :sequence             => 4,
            :datatype             => :string,
            :minimum              => 1,
            :maximum              => 1,
            :required             => true,
            :data_element_number  => 'I17'

    field   :name                 => 'InterchangeNoteCode',
            :sequence             => 5,
            :datatype             => :string,
            :minimum              => 3,
            :maximum              => 3,
            :required             => true,
            :data_element_number  => 'I18'
  end
end