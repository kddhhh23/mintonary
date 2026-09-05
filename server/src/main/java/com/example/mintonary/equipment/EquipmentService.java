package com.example.mintonary.equipment;

import com.example.mintonary.equipment.dto.EquipmentDetailResponse;
import com.example.mintonary.equipment.dto.EquipmentListResponse;
import com.example.mintonary.equipment.dto.EquipmentRegisterRequest;
import com.example.mintonary.equipment.dto.GripChangeRequest;
import com.example.mintonary.equipment.dto.StatusChangeRequest;
import com.example.mintonary.equipment.dto.StringAlarmRequest;
import com.example.mintonary.equipment.dto.StringChangeRequest;
import com.example.mintonary.equipment.model.GripModel;
import com.example.mintonary.equipment.model.GripType;
import com.example.mintonary.equipment.model.RacketModel;
import com.example.mintonary.equipment.model.RacketModelRepository;
import com.example.mintonary.equipment.model.ShoeModel;
import com.example.mintonary.equipment.model.ShoeModelRepository;
import com.example.mintonary.equipment.model.StringModel;
import com.example.mintonary.equipment.model.GripModelRepository;
import com.example.mintonary.equipment.model.StringModelRepository;
import com.example.mintonary.expense.Expense;
import com.example.mintonary.expense.ExpenseCategory;
import com.example.mintonary.expense.ExpenseRepository;
import com.example.mintonary.member.Member;
import com.example.mintonary.member.MemberRepository;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class EquipmentService {

    private final MemberRepository memberRepository;
    private final EquipmentRepository equipmentRepository;
    private final MyRacketRepository myRacketRepository;
    private final MyShoeRepository myShoeRepository;
    private final RacketStringHistoryRepository stringHistoryRepository;
    private final RacketGripHistoryRepository gripHistoryRepository;
    private final RacketModelRepository racketModelRepository;
    private final ShoeModelRepository shoeModelRepository;
    private final StringModelRepository stringModelRepository;
    private final GripModelRepository gripModelRepository;
    private final ExpenseRepository expenseRepository;

    /** 장비 등록 — 라켓이면 초기 스트링/그립 이력까지 함께 기록한다 */
    @Transactional
    public Long register(Long memberId, EquipmentRegisterRequest request) {
        Member member = memberRepository.getReferenceById(memberId);
        Equipment equipment = equipmentRepository.save(Equipment.create(
                member,
                request.type(),
                request.purchaseDate(),
                request.price(),
                request.memo()
        ));

        String equipmentName;
        if (request.type() == EquipmentType.RACKET) {
            RacketModel model = racketModelRepository.findById(request.modelId())
                    .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 라켓 모델입니다."));
            equipmentName = model.getBrand() + " " + model.getName();
            MyRacket myRacket = myRacketRepository.save(MyRacket.create(equipment, model));

            // 교체일을 따로 안 보냈으면 구매일을 쓴다 (앱 등록 화면과 같은 규칙)
            if (request.string() != null) {
                LocalDate strungAt = firstNonNull(request.string().strungAt(), request.purchaseDate());
                if (strungAt == null) {
                    throw new IllegalArgumentException("스트링 교체일 또는 구매일이 필요합니다.");
                }
                stringHistoryRepository.save(RacketStringHistory.create(
                        myRacket,
                        getOrCreateStringModel(request.string().name()),
                        request.string().tension(),
                        strungAt,
                        null
                ));
            }
            if (request.grip() != null) {
                LocalDate wrappedAt = firstNonNull(request.grip().wrappedAt(), request.purchaseDate());
                if (wrappedAt == null) {
                    throw new IllegalArgumentException("그립 교체일 또는 구매일이 필요합니다.");
                }
                gripHistoryRepository.save(RacketGripHistory.create(
                        myRacket,
                        getOrCreateGripModel(request.grip().name(), request.grip().type()),
                        wrappedAt,
                        null
                ));
            }
        } else {
            ShoeModel model = shoeModelRepository.findById(request.modelId())
                    .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 신발 모델입니다."));
            equipmentName = model.getBrand() + " " + model.getName();
            myShoeRepository.save(MyShoe.create(equipment, model));
        }

        if (Boolean.TRUE.equals(request.addToExpenses())) {
            if (request.price() == null || request.price() <= 0) {
                throw new IllegalArgumentException("지출에 추가하려면 장비 가격이 필요합니다.");
            }
            expenseRepository.save(Expense.create(
                    member,
                    firstNonNull(request.purchaseDate(), LocalDate.now()),
                    ExpenseCategory.EQUIPMENT,
                    equipmentName,
                    request.price(),
                    null
            ));
        }

        return equipment.getId();
    }

    /** 장비 탭 목록 */
    public EquipmentListResponse list(Long memberId) {
        List<EquipmentListResponse.RacketSummary> rackets = new ArrayList<>();
        List<EquipmentListResponse.ShoeSummary> shoes = new ArrayList<>();

        for (Equipment equipment : equipmentRepository.findAllByMemberIdOrderByIdDesc(memberId)) {
            if (equipment.getType() == EquipmentType.RACKET) {
                MyRacket myRacket = getMyRacket(equipment);
                RacketStringHistory string = stringHistoryRepository
                        .findFirstByMyRacketIdOrderByStrungAtDescIdDesc(myRacket.getId())
                        .orElse(null);
                RacketGripHistory grip = gripHistoryRepository
                        .findFirstByMyRacketIdOrderByWrappedAtDescIdDesc(myRacket.getId())
                        .orElse(null);
                rackets.add(new EquipmentListResponse.RacketSummary(
                        equipment.getId(),
                        myRacket.getRacketModel().getBrand(),
                        myRacket.getRacketModel().getName(),
                        equipment.getPurchaseDate(),
                        equipment.getPrice(),
                        equipment.isInUse(),
                        string == null ? null : string.getStringModel().getName(),
                        string == null ? null : string.getTension(),
                        string == null ? null : string.getStrungAt(),
                        grip == null ? null : grip.getGripModel().getName(),
                        grip == null ? null : grip.getWrappedAt()
                ));
            } else {
                MyShoe myShoe = getMyShoe(equipment);
                shoes.add(new EquipmentListResponse.ShoeSummary(
                        equipment.getId(),
                        myShoe.getShoeModel().getBrand(),
                        myShoe.getShoeModel().getName(),
                        equipment.getPurchaseDate(),
                        equipment.getPrice(),
                        equipment.isInUse()
                ));
            }
        }
        return new EquipmentListResponse(rackets, shoes);
    }

    /** 장비 상세 — 라켓이면 스트링/그립 이력 포함 */
    public EquipmentDetailResponse detail(Long memberId, Long equipmentId) {
        Equipment equipment = getOwned(memberId, equipmentId);

        EquipmentDetailResponse.RacketInfo racketInfo = null;
        EquipmentDetailResponse.ShoeInfo shoeInfo = null;

        if (equipment.getType() == EquipmentType.RACKET) {
            MyRacket myRacket = getMyRacket(equipment);
            RacketModel model = myRacket.getRacketModel();
            List<EquipmentDetailResponse.StringHistoryItem> stringHistories = stringHistoryRepository
                    .findAllByMyRacketIdOrderByStrungAtDescIdDesc(myRacket.getId()).stream()
                    .map(history -> new EquipmentDetailResponse.StringHistoryItem(
                            history.getId(),
                            history.getStringModel().getName(),
                            history.getTension(),
                            history.getStrungAt()
                    ))
                    .toList();
            List<EquipmentDetailResponse.GripHistoryItem> gripHistories = gripHistoryRepository
                    .findAllByMyRacketIdOrderByWrappedAtDescIdDesc(myRacket.getId()).stream()
                    .map(history -> new EquipmentDetailResponse.GripHistoryItem(
                            history.getId(),
                            history.getGripModel().getName(),
                            history.getGripModel().getType(),
                            history.getWrappedAt()
                    ))
                    .toList();
            racketInfo = new EquipmentDetailResponse.RacketInfo(
                    model.getBrand(),
                    model.getSeries(),
                    model.getName(),
                    model.getWeight() == null ? null : model.getWeight().name(),
                    model.getBalance(),
                    model.getFlex(),
                    myRacket.getStringAlarmDate(),
                    stringHistories,
                    gripHistories
            );
        } else {
            MyShoe myShoe = getMyShoe(equipment);
            ShoeModel model = myShoe.getShoeModel();
            shoeInfo = new EquipmentDetailResponse.ShoeInfo(
                    model.getBrand(),
                    model.getName(),
                    model.getWidth()
            );
        }

        return new EquipmentDetailResponse(
                equipment.getId(),
                equipment.getType(),
                equipment.getPurchaseDate(),
                equipment.getPrice(),
                equipment.getMemo(),
                equipment.isInUse(),
                racketInfo,
                shoeInfo
        );
    }

    /** 스트링 교체 기록 추가 */
    @Transactional
    public Long addStringChange(Long memberId, Long equipmentId, StringChangeRequest request) {
        MyRacket myRacket = getMyRacket(getOwned(memberId, equipmentId));
        RacketStringHistory history = stringHistoryRepository.save(RacketStringHistory.create(
                myRacket,
                getOrCreateStringModel(request.name()),
                request.tension(),
                request.strungAt(),
                request.memo()
        ));
        return history.getId();
    }

    /** 스트링 교체 기록 삭제 */
    @Transactional
    public void deleteStringChange(Long memberId, Long equipmentId, Long historyId) {
        MyRacket myRacket = getMyRacket(getOwned(memberId, equipmentId));
        RacketStringHistory history = stringHistoryRepository.findByIdAndMyRacketId(historyId, myRacket.getId())
                .orElseThrow(() -> new NoSuchElementException("교체 이력을 찾을 수 없습니다."));
        stringHistoryRepository.delete(history);
    }

    /** 그립 교체 기록 추가 */
    @Transactional
    public Long addGripChange(Long memberId, Long equipmentId, GripChangeRequest request) {
        MyRacket myRacket = getMyRacket(getOwned(memberId, equipmentId));
        RacketGripHistory history = gripHistoryRepository.save(RacketGripHistory.create(
                myRacket,
                getOrCreateGripModel(request.name(), request.type()),
                request.wrappedAt(),
                request.memo()
        ));
        return history.getId();
    }

    /** 그립 교체 기록 삭제 */
    @Transactional
    public void deleteGripChange(Long memberId, Long equipmentId, Long historyId) {
        MyRacket myRacket = getMyRacket(getOwned(memberId, equipmentId));
        RacketGripHistory history = gripHistoryRepository.findByIdAndMyRacketId(historyId, myRacket.getId())
                .orElseThrow(() -> new NoSuchElementException("교체 이력을 찾을 수 없습니다."));
        gripHistoryRepository.delete(history);
    }

    /** 스트링 교체 알림 날짜 변경 — null이면 알림 해제 */
    @Transactional
    public void changeStringAlarm(Long memberId, Long equipmentId, StringAlarmRequest request) {
        MyRacket myRacket = getMyRacket(getOwned(memberId, equipmentId));
        myRacket.changeStringAlarmDate(request.alarmDate());
    }

    /** 사용 상태 변경 */
    @Transactional
    public void changeStatus(Long memberId, Long equipmentId, StatusChangeRequest request) {
        Equipment equipment = getOwned(memberId, equipmentId);
        if (request.inUse()) {
            equipment.restore();
        } else {
            equipment.retire();
        }
    }

    /** 장비 삭제 — 라켓이면 교체 이력까지 함께 지운다 */
    @Transactional
    public void delete(Long memberId, Long equipmentId) {
        Equipment equipment = getOwned(memberId, equipmentId);
        if (equipment.getType() == EquipmentType.RACKET) {
            MyRacket myRacket = getMyRacket(equipment);
            stringHistoryRepository.deleteAllByMyRacketId(myRacket.getId());
            gripHistoryRepository.deleteAllByMyRacketId(myRacket.getId());
            myRacketRepository.delete(myRacket);
        } else {
            myShoeRepository.delete(getMyShoe(equipment));
        }
        equipmentRepository.delete(equipment);
    }

    private Equipment getOwned(Long memberId, Long equipmentId) {
        return equipmentRepository.findByIdAndMemberId(equipmentId, memberId)
                .orElseThrow(() -> new NoSuchElementException("장비를 찾을 수 없습니다."));
    }

    private MyRacket getMyRacket(Equipment equipment) {
        return myRacketRepository.findByEquipmentId(equipment.getId())
                .orElseThrow(() -> new IllegalArgumentException("라켓 장비가 아닙니다."));
    }

    private MyShoe getMyShoe(Equipment equipment) {
        return myShoeRepository.findByEquipmentId(equipment.getId())
                .orElseThrow(() -> new IllegalArgumentException("신발 장비가 아닙니다."));
    }

    /** 스트링은 이름으로 찾고 없으면 만든다 (자유 입력이라 마스터에 없을 수 있음) */
    private StringModel getOrCreateStringModel(String name) {
        return stringModelRepository.findFirstByName(name)
                .orElseGet(() -> stringModelRepository.save(StringModel.create(name)));
    }

    /** 그립도 이름+종류로 찾고 없으면 만든다 */
    private GripModel getOrCreateGripModel(String name, GripType type) {
        return gripModelRepository.findFirstByNameAndType(name, type)
                .orElseGet(() -> gripModelRepository.save(GripModel.create(name, type)));
    }

    private static LocalDate firstNonNull(LocalDate first, LocalDate second) {
        return first != null ? first : second;
    }
}
