module Hippo::Segments
  class ISA < Base

    segment_identifier  'ISA'
    segment_fixed_width

    field   :name                 => 'AuthorizationInformationQualifier',
            :sequence             => 1,
            :datatype             => :string,
            :minimum              => 2,
            :maximum              => 2,
            :required             => true,
            :data_element_number  => 'I01'

    field   :name                 => 'AuthorizationInformation',
            :sequence             => 2,
            :datatype             => :string,
            :minimum              => 10,
            :maximum              => 10,
            :required             => true,
            :data_element_number  => 'I02'

    field   :name                 => 'SecurityInformationQualifier',
            :sequence             => 3,
            :datatype             => :string,
            :minimum              => 2,
            :maximum              => 2,
            :required             => true,
            :data_element_number  => 'I03'

    field   :name                 => 'SecurityInformation',
            :sequence             => 4,
            :datatype             => :string,
            :minimum              => 10,
            :maximum              => 10,
            :required             => true,
            :data_element_number  => 'I04'

    field   :name                 => 'InterchangeIdQualifier',
            :sequence             => 5,
            :datatype             => :string,
            :minimum              => 2,
            :maximum              => 2,
            :required             => true,
            :data_element_number  => 'I05'

    field   :name                 => 'InterchangeSenderId',
            :sequence             => 6,
            :datatype             => :string,
            :minimum              => 15,
            :maximum              => 15,
            :required             => true,
            :data_element_number  => 'I06'

    field   :name                 => 'InterchangeIdQualifier',
            :sequence             => 7,
            :datatype             => :string,
            :minimum              => 2,
            :maximum              => 2,
            :required             => true,
            :data_element_number  => 'I05'

    field   :name                 => 'InterchangeReceiverId',
            :sequence             => 8,
            :datatype             => :string,
            :minimum              => 15,
            :maximum              => 15,
            :required             => true,
            :data_element_number  => 'I07'

    field   :name                 => 'InterchangeDate',
            :sequence             => 9,
            :datatype             => :string,
            :minimum              => 6,
            :maximum              => 6,
            :required             => true,
            :data_element_number  => 'I08'

    field   :name                 => 'InterchangeTime',
            :sequence             => 10,
            :datatype             => :string,
            :minimum              => 4,
            :maximum              => 4,
            :required             => true,
            :data_element_number  => 'I09'

    field   :name                 => 'RepetitionSeparator',
            :sequence             => 11,
            :datatype             => :string,
            :minimum              => 1,
            :maximum              => 1,
            :required             => true,
            :data_element_number  => 'I65'

    field   :name                 => 'InterchangeControlVersionNumber',
            :sequence             => 12,
            :datatype             => :string,
            :minimum              => 5,
            :maximum              => 5,
            :required             => true,
            :data_element_number  => 'I11'

    field   :name                 => 'InterchangeControlNumber',
            :sequence             => 13,
            :datatype             => :string,
            :minimum              => 9,
            :maximum              => 9,
            :required             => true,
            :data_element_number  => 'I12'

    field   :name                 => 'AcknowledgmentRequested',
            :sequence             => 14,
            :datatype             => :string,
            :minimum              => 1,
            :maximum              => 1,
            :required             => true,
            :data_element_number  => 'I13'

    field   :name                 => 'InterchangeUsageIndicator',
            :sequence             => 15,
            :datatype             => :string,
            :minimum              => 1,
            :maximum              => 1,
            :required             => true,
            :data_element_number  => 'I14'

    field   :name                 => 'ComponentElementSeparator',
            :sequence             => 16,
            :datatype             => :string,
            :minimum              => 1,
            :maximum              => 1,
            :required             => true,
            :data_element_number  => 'I15'

  end
end
